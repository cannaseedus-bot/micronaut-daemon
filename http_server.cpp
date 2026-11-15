#include "http_server.h"
#include "chat.h"
#include "common.h"
#include <sstream>
#include <iostream>

#ifdef _WIN32
#include <winsock2.h>
#include <ws2tcpip.h>
#pragma comment(lib, "Ws2_32.lib")
using socket_t = SOCKET;
static void close_socket(socket_t s) { closesocket(s); }
#else
#include <arpa/inet.h>
#include <netinet/in.h>
#include <sys/socket.h>
#include <unistd.h>
using socket_t = int;
static void close_socket(socket_t s) { close(s); }
#endif

namespace micronaut {
namespace {
bool send_all(socket_t socket, const std::string& value) {
    std::size_t sent = 0;
    while (sent < value.size()) {
        const int n = ::send(socket, value.data() + sent, static_cast<int>(value.size() - sent), 0);
        if (n <= 0) return false;
        sent += static_cast<std::size_t>(n);
    }
    return true;
}

void reply(socket_t socket, int status, const std::string& reason, const std::string& body) {
    std::ostringstream out;
    out << "HTTP/1.1 " << status << ' ' << reason << "\r\n"
        << "Content-Type: application/json; charset=utf-8\r\n"
        << "Access-Control-Allow-Origin: *\r\n"
        << "Access-Control-Allow-Methods: GET, POST, OPTIONS\r\n"
        << "Access-Control-Allow-Headers: Content-Type, Authorization\r\n"
        << "Connection: close\r\nContent-Length: " << body.size() << "\r\n\r\n" << body;
    send_all(socket, out.str());
}

void handle(socket_t client) {
    std::string request;
    char buffer[4096];
    std::size_t header_end = std::string::npos;
    std::size_t content_length = 0;
    while (request.size() < 1024 * 1024) {
        const int n = ::recv(client, buffer, sizeof(buffer), 0);
        if (n <= 0) return;
        request.append(buffer, static_cast<std::size_t>(n));
        header_end = request.find("\r\n\r\n");
        if (header_end != std::string::npos) {
            const auto headers = request.substr(0, header_end);
            const auto marker = headers.find("Content-Length:");
            if (marker != std::string::npos) {
                try { content_length = static_cast<std::size_t>(std::stoull(headers.substr(marker + 15))); }
                catch (...) { reply(client, 400, "Bad Request", "{\"error\":\"invalid content length\"}"); return; }
            }
            if (request.size() >= header_end + 4 + content_length) break;
        }
    }
    if (header_end == std::string::npos) { reply(client, 400, "Bad Request", "{\"error\":\"invalid HTTP request\"}"); return; }
    const auto first_end = request.find("\r\n");
    const auto line = request.substr(0, first_end);
    std::istringstream request_line(line);
    std::string method, path, version;
    request_line >> method >> path >> version;
    if (method == "OPTIONS") { reply(client, 204, "No Content", ""); return; }
    if (method == "GET" && (path == "/health" || path == "/api/health")) {
        reply(client, 200, "OK", "{\"ok\":true,\"service\":\"micronaut-daemon\"}"); return;
    }
    if (method != "POST" || (path != "/api/chat" && path != "/v1/chat/completions")) {
        reply(client, 404, "Not Found", "{\"error\":\"route not found\"}"); return;
    }
    const std::string body = request.substr(header_end + 4, content_length);
    const Json payload = parse_json_loose(body);
    MicronautOp op;
    op.id = "http-" + now_ms_string();
    op.kind = "micronaut.request.v1";
    op.op = "chat.generate";
    op.payload = payload;
    const auto prompt = payload.get("prompt", payload.get("content", ""));
    op.payload.flat["prompt"] = prompt;
    auto result = chat_execute(op);
    if (!result.ok) { reply(client, 500, "Internal Server Error", "{\"error\":\"chat failed\"}"); return; }
    const auto response = parse_json_loose(result.result_json).get("text", "");
    if (path == "/v1/chat/completions") {
        reply(client, 200, "OK", "{\"id\":\"" + json_escape(op.id) + "\",\"object\":\"chat.completion\",\"choices\":[{\"index\":0,\"message\":{\"role\":\"assistant\",\"content\":\"" + json_escape(response) + "\"},\"finish_reason\":\"stop\"}]}");
    } else {
        reply(client, 200, "OK", result.result_json);
    }
}
}

int run_http_server(unsigned short port) {
#ifdef _WIN32
    WSADATA data;
    if (WSAStartup(MAKEWORD(2, 2), &data) != 0) return 1;
#endif
    socket_t listener = ::socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
#ifdef _WIN32
    if (listener == INVALID_SOCKET) { WSACleanup(); return 1; }
#else
    if (listener < 0) return 1;
#endif
    sockaddr_in address{};
    address.sin_family = AF_INET;
    address.sin_port = htons(port);
    address.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
    if (::bind(listener, reinterpret_cast<sockaddr*>(&address), sizeof(address)) != 0 || ::listen(listener, 16) != 0) {
        close_socket(listener);
#ifdef _WIN32
        WSACleanup();
#endif
        return 1;
    }
    std::cout << "ELIZA Micronaut HTTP API listening at http://127.0.0.1:" << port
              << " (GET /health, POST /api/chat, POST /v1/chat/completions)\n" << std::flush;
    for (;;) {
        socket_t client = ::accept(listener, nullptr, nullptr);
#ifdef _WIN32
        if (client == INVALID_SOCKET) continue;
#else
        if (client < 0) continue;
#endif
        handle(client);
        close_socket(client);
    }
}
}
