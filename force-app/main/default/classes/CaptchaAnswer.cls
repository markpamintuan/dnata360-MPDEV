public with sharing class CaptchaAnswer {

    public CaptchaAnswer() {
    }

    public CaptchaAnswer(String value, String path ) {
        this.value = value;
        this.path = path;
    }

    private String path;
    private String value;
    private String obfuscatedName;

    public String getPath() {
        return path;
    }

    public void setPath(String path) {
        this.path = path;
    }

    public String getValue() {
        return value;
    }

    public void setValue(String value) {
        this.value = value;
    }

    public override String toString() {
        return JSON.serializePretty(this);
    }

    public String getObfuscatedName() {
        return path;
    }
    
}