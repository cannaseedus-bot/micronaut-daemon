#pragma once
#include <string>
#include <vector>

namespace micronaut::svml {
struct Variant { std::string suffix, path; bool present=false, loaded=false; };
std::vector<Variant> inspect(const std::string& driver_directory);
}
