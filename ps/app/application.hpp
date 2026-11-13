#pragma once

#include <QCoreApplication>

namespace mps {
class Application final {
public:
    Application(int& argc, char** argv);
    int run();

private:
    QCoreApplication application_;
};
} // namespace mps
