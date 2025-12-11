package kr.co.bnkfirst.kiwoom;

import lombok.Getter;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Getter
@Component
@ConfigurationProperties(prefix = "kiwoom")
public class KiwoomAuthProperties {
    private String appkey;
    private String secret;
    private String tokenUrl;

    public void setAppkey(String appkey) { this.appkey = appkey; }
    public void setSecret(String secret) { this.secret = secret; }
    public void setTokenUrl(String tokenUrl) { this.tokenUrl = tokenUrl; }
}