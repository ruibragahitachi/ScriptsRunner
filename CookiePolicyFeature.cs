using DPG.Ecommerce.ConfigurationSettings;

namespace DPG.Ecommerce.Application.FeatureToggles
{
    public class CookiePolicyFeature : ICookiePolicyFeature
    {
        private readonly IApplicationSettings _applicationSettings;

        public CookiePolicyFeature(IApplicationSettings applicationSettings)
        {
            _applicationSettings = applicationSettings;
        }

        public bool IsEnabled()
        {
            return _applicationSettings.GetSetting("CookiePolicy", "Feature", false);
        }
    }
}
