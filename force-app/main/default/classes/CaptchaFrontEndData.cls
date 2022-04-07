public with sharing class CaptchaFrontEndData {

    private String imageName;
    private String imageFieldName;
    private List<String> values;
    private String audioFieldName;

    public List<CaptchaAnswer> choices{get; set;}
    
    public CaptchaFrontEndData(String imageName, String imageFieldName,
            List<String> imageOptions, String audioFieldName, List<CaptchaAnswer> listChoices) {
        this.imageName = imageName;
        this.imageFieldName = imageFieldName;
        this.values = new List<string>(imageOptions);
        this.audioFieldName = audioFieldName;
        choices = listChoices;
    }

    public String getImageName() {
        return imageName;
    }

    public String getImageFieldName() {
        return imageFieldName;
    }

    public List<String> getValues() {
        return values;
    }

    public String getAudioFieldName() {
        return audioFieldName;
    }
}