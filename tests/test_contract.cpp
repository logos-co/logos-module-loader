// Self-contained test for the logos-module-loader contract: the
// ModuleFormatLoader interface must be implementable against the
// ModuleDescriptor from logos-container.
#include <gtest/gtest.h>

#include <logos_module_loader/module_format_loader.h>

#include <string>
#include <vector>

namespace {
// A minimal ModuleFormatLoader implementation must compile against the interface.
class NullFormatLoader : public LogosCore::ModuleFormatLoader {
public:
    std::string id() const override { return "null"; }
    bool canHandle(const LogosCore::ModuleDescriptor&) const override { return false; }
    std::string resolveHostBinary(const LogosCore::ModuleDescriptor&) const override { return {}; }
    std::vector<std::string> buildArguments(const LogosCore::ModuleDescriptor&) const override { return {}; }
};
} // namespace

TEST(ModuleFormatLoader, InterfaceIsImplementable) {
    NullFormatLoader l;
    EXPECT_EQ(l.id(), "null");

    LogosCore::ModuleDescriptor desc;
    desc.format = "qt-plugin";
    EXPECT_FALSE(l.canHandle(desc));
    EXPECT_TRUE(l.resolveHostBinary(desc).empty());
    EXPECT_TRUE(l.buildArguments(desc).empty());
}
