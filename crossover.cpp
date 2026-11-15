#include "evolution_core.h"

#include <algorithm>
#include <cstdlib>

Genome crossover_single_point(const Genome& a, const Genome& b) {
  if (a.empty()) return b;
  if (b.empty()) return a;

  const std::size_t n = (std::min)(a.size(), b.size());
  const std::size_t cut = static_cast<std::size_t>(std::rand()) % n;

  Genome child;
  child.reserve((std::max)(a.size(), b.size()));
  child.insert(child.end(), a.begin(), a.begin() + cut);
  child.insert(child.end(), b.begin() + cut, b.end());
  return child;
}

Genome crossover_multi_point(const Genome& a, const Genome& b) {
  if (a.empty()) return b;
  if (b.empty()) return a;

  const std::size_t n = (std::min)(a.size(), b.size());
  Genome child;
  child.reserve(n);
  for (std::size_t i = 0; i < n; ++i) {
    child.push_back((std::rand() % 2) ? a[i] : b[i]);
  }
  return child;
}
