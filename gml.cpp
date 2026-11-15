// CCC4 stage-1 topology loader. C++17; no third-party dependencies.
#include <algorithm>
#include <array>
#include <cstdint>
#include <cstring>
#include <fstream>
#include <iostream>
#include <map>
#include <set>
#include <sstream>
#include <stdexcept>
#include <string>
#include <utility>
#include <vector>

using Fields = std::map<std::string, std::string>;
struct Item { Fields fields; };
struct Graph { Fields fields; std::vector<Item> nodes, edges; };

[[noreturn]] static void fail(const std::string& s) { throw std::runtime_error("contract violation: " + s); }

class Parser {
    const std::string& s_; size_t p_ = 0;
    void space() { while (p_ < s_.size() && (s_[p_] == ' ' || s_[p_] == '\t' || s_[p_] == '\r' || s_[p_] == '\n')) ++p_; }
    std::string token() {
        space(); if (p_ == s_.size()) fail("unexpected end of GML");
        if (s_[p_] == '"') {
            ++p_; std::string out;
            while (p_ < s_.size() && s_[p_] != '"') {
                if (s_[p_] == '\\') { if (++p_ == s_.size()) fail("unfinished escape"); }
                out += s_[p_++];
            }
            if (p_ == s_.size()) fail("unterminated string"); ++p_; return out;
        }
        size_t start = p_;
        while (p_ < s_.size() && s_[p_] != '[' && s_[p_] != ']' && s_[p_] != '"' && s_[p_] != ' ' && s_[p_] != '\t' && s_[p_] != '\r' && s_[p_] != '\n') ++p_;
        if (start == p_) fail("expected token"); return s_.substr(start, p_ - start);
    }
    void bracket(char c) { space(); if (p_ == s_.size() || s_[p_] != c) fail(std::string("expected '") + c + "'"); ++p_; }
    void item(Item& out) {
        bracket('[');
        for (;;) {
            space(); if (p_ == s_.size()) fail("unclosed list");
            if (s_[p_] == ']') { ++p_; return; }
            auto key = token(); space();
            if (p_ < s_.size() && s_[p_] == '[') fail("nested list in " + key);
            if (!out.fields.emplace(key, token()).second) fail("duplicate field " + key);
        }
    }
public:
    explicit Parser(const std::string& s) : s_(s) {}
    Graph parse() {
        if (token() != "graph") fail("expected graph"); bracket('['); Graph g;
        for (;;) {
            space(); if (p_ == s_.size()) fail("unclosed graph");
            if (s_[p_] == ']') { ++p_; break; }
            auto key = token();
            if (key == "node" || key == "edge") {
                Item v; item(v); (key == "node" ? g.nodes : g.edges).push_back(std::move(v));
            } else {
                space(); if (p_ < s_.size() && s_[p_] == '[') fail("unexpected list " + key);
                if (!g.fields.emplace(key, token()).second) fail("duplicate field " + key);
            }
        }
        space(); if (p_ != s_.size()) fail("trailing tokens"); return g;
    }
};

static const std::string& required(const Fields& f, const std::string& key) {
    auto it = f.find(key); if (it == f.end()) fail("missing " + key); return it->second;
}
static int integer(const std::string& s) {
    if (s.empty()) fail("empty integer"); size_t p = 0;
    if (s[0] == '-') p = 1;
    if (p == s.size()) fail("invalid integer " + s);
    for (; p < s.size(); ++p) if (s[p] < '0' || s[p] > '9') fail("invalid integer " + s);
    try { size_t used; int n = std::stoi(s, &used); if (used != s.size()) fail("invalid integer " + s); return n; }
    catch (const std::exception&) { fail("integer out of range " + s); }
}
static void fields(const Fields& f, const std::set<std::string>& allowed, const std::set<std::string>& needed) {
    for (const auto& x : f) if (!allowed.count(x.first)) fail("unknown field " + x.first);
    for (const auto& x : needed) required(f, x);
}
static void symbolic(const Fields& f, const std::set<std::string>& exempt) {
    for (const auto& x : f) if (!exempt.count(x.first)) {
        if (x.second.empty() || x.second[0] == '-' || (x.second[0] >= '0' && x.second[0] <= '9'))
            fail("invalid symbolic value for " + x.first);
    }
}
static std::set<std::pair<int,int>> expected_edges() {
    std::set<std::pair<int,int>> out;
    auto add = [&](int a, int b) { if (a > b) std::swap(a,b); out.insert({a,b}); };
    for (int x=0; x<16; ++x) for (int y=0; y<4; ++y) {
        int a=4*x+y; add(a,4*x+((y+1)&3)); add(a,4*x+((y+3)&3)); add(a,4*(x^(1<<y))+y);
    }
    return out;
}

// SHA-256, using the standard round constants and initial state.
class Sha256 {
    std::array<uint32_t,8> h_{{0x6a09e667,0xbb67ae85,0x3c6ef372,0xa54ff53a,0x510e527f,0x9b05688c,0x1f83d9ab,0x5be0cd19}};
    std::vector<uint8_t> data_;
    static uint32_t r(uint32_t x,int n) { return (x>>n)|(x<<(32-n)); }
public:
    void update(const std::vector<uint8_t>& b) { data_.insert(data_.end(),b.begin(),b.end()); }
    std::string final() {
        static const uint32_t K[64]={0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2};
        uint64_t bits=uint64_t(data_.size())*8; data_.push_back(0x80);
        while (data_.size()%64!=56) data_.push_back(0);
        for(int i=7;i>=0;--i) data_.push_back(uint8_t(bits>>(8*i)));
        for(size_t off=0;off<data_.size();off+=64) {
            uint32_t w[64]; for(int i=0;i<16;++i) { size_t j=off+4*i; w[i]=(uint32_t(data_[j])<<24)|(uint32_t(data_[j+1])<<16)|(uint32_t(data_[j+2])<<8)|data_[j+3]; }
            for(int i=16;i<64;++i) w[i]=w[i-16]+(r(w[i-15],7)^r(w[i-15],18)^(w[i-15]>>3))+w[i-7]+(r(w[i-2],17)^r(w[i-2],19)^(w[i-2]>>10));
            auto a=h_[0],b=h_[1],c=h_[2],d=h_[3],e=h_[4],f=h_[5],g=h_[6],hh=h_[7];
            for(int i=0;i<64;++i) { uint32_t t1=hh+(r(e,6)^r(e,11)^r(e,25))+((e&f)^((~e)&g))+K[i]+w[i]; uint32_t t2=(r(a,2)^r(a,13)^r(a,22))+((a&b)^(a&c)^(b&c)); hh=g;g=f;f=e;e=d+t1;d=c;c=b;b=a;a=t1+t2; }
            h_[0]+=a;h_[1]+=b;h_[2]+=c;h_[3]+=d;h_[4]+=e;h_[5]+=f;h_[6]+=g;h_[7]+=hh;
        }
        const char* hex="0123456789abcdef"; std::string out;
        for(uint32_t v:h_) for(int i=3;i>=0;--i) { uint8_t b=uint8_t(v>>(8*i));out+=hex[b>>4];out+=hex[b&15]; }
        return out;
    }
};

struct Identity { std::string topology_hash, contract_hash; };

static Identity load(const std::string& path) {
    std::ifstream in(path,std::ios::binary); if(!in) fail("cannot open " + path);
    std::stringstream ss;ss<<in.rdbuf(); Graph g=Parser(ss.str()).parse();
    fields(g.fields,{"comment","directed","id","schema","node_role","topology","topology_mutable","binding_policy","input_binding","parameter_binding","state_binding","execution_policy","label"},{"directed","schema","node_role","topology","topology_mutable","binding_policy","input_binding","parameter_binding","state_binding","execution_policy"});
    if(required(g.fields,"directed")!="0" || required(g.fields,"topology_mutable")!="0" || required(g.fields,"binding_policy")!="external" || required(g.fields,"topology")!="CCC4") fail("invalid topology header");
    symbolic(g.fields,{"comment","id","label","directed","topology_mutable"});
    const auto& schema=required(g.fields,"schema");
    if(schema!="ccc4.neuron.v1" && schema!="ccc4.tensor.v1" && schema!="ccc4.micronaut.v1") fail("unknown schema " + schema);
    std::set<std::string> nr={"id","role","dtype","operator","state_ref"},er={"source","target","label","verb","edge_role"};
    if(schema=="ccc4.neuron.v1") {nr.insert("activation");nr.insert("bias_ref");er.insert("weight_ref");}
    if(schema=="ccc4.tensor.v1") {nr.insert("activation");nr.insert("shape_ref");nr.insert("aggregate");er.insert("weight_ref");}
    if(schema=="ccc4.micronaut.v1") {nr.insert("phase_ref");nr.insert("capability_ref");nr.insert("authority");er.insert("gate");er.insert("dispatch");}
    auto na=nr;na.insert({"label","x","y","z"});
    if(g.nodes.size()!=64 || g.edges.size()!=96) fail("wrong node or edge count");
    std::set<int> ids;
    for(const auto& n:g.nodes) { fields(n.fields,na,nr);symbolic(n.fields,{"id","label","x","y","z"});int id=integer(required(n.fields,"id"));if(id<0||id>=64||!ids.insert(id).second)fail("invalid or duplicate node id"); }
    std::set<std::pair<int,int>> edges;
    for(const auto& e:g.edges) {
        fields(e.fields,er,er);symbolic(e.fields,{"source","target","label"});
        int a=integer(required(e.fields,"source")),b=integer(required(e.fields,"target"));
        if(!ids.count(a)||!ids.count(b)||a==b)fail("invalid edge endpoint");
        int xa=a/4,xb=b/4,ya=a%4,yb=b%4;const auto& label=required(e.fields,"label");
        bool cycle=xa==xb && ((ya-yb+4)%4==1 || (ya-yb+4)%4==3);
        // The node position y selects the XOR bit; the label must name y.
        bool xor_edge=ya==yb && (xa^xb)==(1<<ya);
        if((cycle && label!="cycle") || (xor_edge && label!="xor:bit"+std::to_string(ya)) || (!cycle&&!xor_edge)) fail("edge label or CCC4 endpoints invalid");
        if(a>b)std::swap(a,b);if(!edges.insert({a,b}).second)fail("duplicate edge pair");
    }
    if(edges!=expected_edges()) fail("edge set differs from CCC4");
    std::vector<uint8_t> bytes; const char* domain="ccc4.topology.v1"; bytes.insert(bytes.end(),domain,domain+std::strlen(domain)+1);
    auto put=[&](uint32_t v){for(int i=0;i<4;++i)bytes.push_back(uint8_t(v>>(8*i)));};
    put(64);put(96);for(int i=0;i<64;++i)put(uint32_t(i));for(auto e:edges){put(uint32_t(e.first));put(uint32_t(e.second));}
    Sha256 sha;sha.update(bytes);auto topology_hash=sha.final();

    // Proposed contract encoding v1: domain, sorted graph declarations, then
    // nodes by ID and edges by canonical endpoint pair. Each field is encoded
    // as a length-prefixed UTF-8 key and value. Presentation fields are absent.
    std::vector<uint8_t> cb;
    const char* contract_domain="ccc4.contract.v1";
    cb.insert(cb.end(),contract_domain,contract_domain+std::strlen(contract_domain)+1);
    auto cput=[&](uint32_t v){for(int i=0;i<4;++i)cb.push_back(uint8_t(v>>(8*i)));};
    auto cstr=[&](const std::string& s){cput(uint32_t(s.size()));cb.insert(cb.end(),s.begin(),s.end());};
    auto cfields=[&](const Fields& f,const std::set<std::string>& exclude){
        uint32_t count=0;for(const auto& kv:f)if(!exclude.count(kv.first))++count;
        cput(count);for(const auto& kv:f)if(!exclude.count(kv.first)){cstr(kv.first);cstr(kv.second);}
    };
    cfields(g.fields,{"comment","id","label"});
    std::map<int,const Fields*> ordered_nodes;
    for(const auto& n:g.nodes) ordered_nodes.emplace(integer(required(n.fields,"id")),&n.fields);
    cput(uint32_t(ordered_nodes.size()));
    for(const auto& n:ordered_nodes){cput(uint32_t(n.first));cfields(*n.second,{"id","label","x","y","z"});}
    std::map<std::pair<int,int>,const Fields*> ordered_edges;
    for(const auto& e:g.edges){int a=integer(required(e.fields,"source")),b=integer(required(e.fields,"target"));if(a>b)std::swap(a,b);ordered_edges.emplace(std::make_pair(a,b),&e.fields);}
    cput(uint32_t(ordered_edges.size()));
    for(const auto& e:ordered_edges){cput(uint32_t(e.first.first));cput(uint32_t(e.first.second));cfields(*e.second,{"source","target"});}
    Sha256 contract_sha;contract_sha.update(cb);
    return {topology_hash,contract_sha.final()};
}
int main(int argc,char**argv) {
    if(argc<2){std::cerr<<"usage: gml <file.gml> [more.gml ...]\n";return 2;}
    int failures=0;std::string first;
    for(int i=1;i<argc;++i)try { auto id=load(argv[i]);std::cout<<argv[i]<<"\n  nodes=64 edges=96 topology_hash="<<id.topology_hash<<" contract_hash="<<id.contract_hash<<"\n";if(first.empty())first=id.topology_hash;else if(id.topology_hash!=first){std::cerr<<"topology hash mismatch\n";++failures;} }
    catch(const std::exception& e){std::cerr<<argv[i]<<": "<<e.what()<<"\n";++failures;}
    return failures?1:0;
}
