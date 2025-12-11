package kr.co.bnkfirst.dbstock;

import lombok.Getter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Getter
@Component
@ConfigurationProperties(prefix = "db")
public class DbAuthProperties {

    private String appkey;
    private String secret;
    private String tokenUrl;
    private String scope;

    public void setAppkey(String appkey) { this.appkey = appkey; }
    public void setSecret(String secret) { this.secret = secret; }
    public void setTokenUrl(String tokenUrl) { this.tokenUrl = tokenUrl; }
    public void setScope(String scope) { this.scope = scope; }
}