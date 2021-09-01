using DPG.Ecommerce.Application.FeatureToggles;
using DPG.Ecommerce.ConfigurationSettings;
using NSubstitute;
using Xunit;

namespace DPG.Ecommerce.UnitTests.v2.Application.FeatureToggles
{
    public class CookiePolicyFeatureTests
    {
        private readonly IApplicationSettings _applicationSettings;
        private readonly CookiePolicyFeature _sut;
        private const string CookiePolicyKey = "CookiePolicy";
        private const string CookiePolicyRegion = "Feature";

        public CookiePolicyFeatureTests()
        {
            _applicationSettings = Substitute.For<IApplicationSettings>();
            _sut = new CookiePolicyFeature(_applicationSettings);
        }

        [Fact]
        public void IsEnabled_WhenCookiePolicyNotSet_ReturnsDefault()
        {
            // Arrange
            _applicationSettings.GetSetting(CookiePolicyKey, CookiePolicyRegion, false);

            // Act
            var actual = _sut.IsEnabled();

            // Assert
            Assert.False(actual);
        }

        [Fact]
        public void IsEnabled_WhenCookiePolicyEnabled_ReturnsTrue()
        {
            // Arrange
            _applicationSettings.GetSetting(CookiePolicyKey, CookiePolicyRegion, false)
                .Returns(true);

            // Act
            var actual = _sut.IsEnabled();

            // Assert
            Assert.True(actual);
        }

        [Fact]
        public void IsEnabled_WhenCookiePolicyDisabled_ReturnsFalse()
        {
            // Arrange
            _applicationSettings.GetSetting(CookiePolicyKey, CookiePolicyRegion, false)
                .Returns(false);

            // Act
            var actual = _sut.IsEnabled();

            // Assert
            Assert.False(actual);
        }

    }
}
