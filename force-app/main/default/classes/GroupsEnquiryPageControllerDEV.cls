/**
* @author: Mark Anthony Pamintuan
* @date: 2 March 2021
* @description: Controller class for GroupsEnquiryPage
* @history:                
*/
public class GroupsEnquiryPageControllerDEV {

    public String supportDetailsOffline { get; set; }
    
    public String caseID {get; set;}
    public string accID { get; set;}
    public String brand {get;set;}
    public String domainID {get; set;}
    public String requestOrigin {get; set;}

    // Captcha code
    public static final integer DEFAULT_NUM_OPTIONS = 5;
    public static final String INIT_PARAM_IMAGE_ASSET_DOC = label.CaptchaDocIdImage;
    public static final String INIT_PARAM_AUDIO_ASSET_DOC = label.CaptchaDocIdAudio;
    private String imagesPath;
    private List<CaptchaAnswer> images;
    private String audioPath;
    private List<CaptchaAnswer> audios;
    public CaptchaAnswer validChoice {get; set;}
    public CaptchaAnswer audioOption {get; set;}
    public CaptchaFrontEndData frontendData {get; set;}
    public string siteNameFromOfflineForm {get;set;}
    
    public boolean isShowCaptcha {get; set;}
    


	public GroupsEnquiryPageControllerDEV(){

        if(ApexPages.currentPage().getParameters().get('caseId') != null){
            caseID = ApexPages.currentPage().getParameters().get('caseId');
        } else {
            caseID = '';
        }

        if(ApexPages.currentPage().getParameters().get('domainId') != null){
            domainID = ApexPages.currentPage().getParameters().get('domainId');
        } else {
            domainID = '';
        }

        if(ApexPages.currentPage().getParameters().get('reqOrigin') != null){
            requestOrigin = ApexPages.currentPage().getParameters().get('reqOrigin');
        } else {
            requestOrigin = '';
        }
        
        brand = ApexPages.currentPage().getParameters().get('brand');  
		
		if(caseID != ''){	
			isShowCaptcha = false;
		} else {
		    initCaptcha();
		    isShowCaptcha = true;			
		}
	
	}


      
    public pagereference proceedToEnquiryForm(){
        try{
            // Call Validiate captcha            
            validateCaptcha();
            //End Call Validiate captcha             

            if(IsValidCaptcha) {
                isShowCaptcha = false;
            }
            return null;
        }
        catch(exception ex){
            system.debug('ERROR MESSAGE: '+ex.getMessage()+', AT: '+ex.getStackTraceString());
            return null;
        }
    }

    public String defaultCaptchaView {get; set;}
    public String userVisualCaptchaAnswer{get; set;}
    public String userAudioCaptchaAnswer{get; set;}
    public boolean IsValidCaptcha {get; set;}

    public void switchCaptcha(){
        if(isValidCaptcha){
            loadVisualCaptcha();
        }
        
    }
    
    private void validateCaptcha(){

        if(defaultCaptchaView == 'visual'){
            system.debug('Visual Captcha Answer ==>' + userVisualCaptchaAnswer);
            IsValidCaptcha = (userVisualCaptchaAnswer != null && userVisualCaptchaAnswer != '') &&
                    userVisualCaptchaAnswer == validChoice.getValue();
        }else{
            system.debug('Visual Captcha Answer ==>' + userAudioCaptchaAnswer);
            IsValidCaptcha = (userAudioCaptchaAnswer != null && userAudioCaptchaAnswer != '')  &&
                    userAudioCaptchaAnswer == audioOption.getValue();
        }

        if(!IsValidCaptcha){
            //reload captcha
            loadVisualCaptcha();
        }
    }


    private void initCaptcha(){
        defaultCaptchaView = 'visual';
        IsValidCaptcha = true;
        loadImages();
        loadAudios();
        loadVisualCaptcha();
    }

    private void loadVisualCaptcha(){
        integer optionCount = DEFAULT_NUM_OPTIONS;
        String salt = NewGuid();
        List<CaptchaAnswer> choices = getRandomCaptchaOptions(optionCount, salt);
        integer randIndex = rand(optionCount);
        if(randIndex < choices.size())
            validChoice = choices.get(randIndex);
        audioOption = getRandomCaptchaAudio(salt);
        String fieldName = hash(NewGuid(), salt);
        String audioFieldName = hash(NewGuid(), salt);
        List<String> frontEndOptions = new List<String>();
        for(CaptchaAnswer choice : choices){
            frontEndOptions.add(choice.getObfuscatedName());
        }
        system.debug(validChoice);
        system.debug(fieldName);
        system.debug(frontEndOptions);
        system.debug(audioFieldName);
        system.debug(choices);
        //if(validChoice != null && validChoice.getValue()!=null && fieldName != null && frontEndOptions != null && audioFieldName != null && choices != null)
        if(validChoice != null)
        frontendData = new CaptchaFrontEndData(
                validChoice.getValue(), fieldName, frontEndOptions, audioFieldName, choices);
    }

    private void loadImages() {
        //resource/1487099446000/Live_Chat_Resources/captcha_assets/images.json
        images = getCaptchaData(INIT_PARAM_IMAGE_ASSET_DOC);

    }
    private void loadAudios() {
        audios = getCaptchaData(INIT_PARAM_AUDIO_ASSET_DOC);
    }

    private List<CaptchaAnswer> getCaptchaData(string docId){
        system.debug(docId);
        List<CaptchaAnswer> data = new List<CaptchaAnswer>();
        try{
            List<Document> docs = [SELECT Body, BodyLength, ContentType FROM Document WHERE id=:docId LIMIT 1];

            String docBodyString = '';
            if(docs.size() >= 1)
                docBodyString = docs[0].Body.toString();

            if(System.Test.isRunningTest()){
                docBodyString = '[{\"path\":\"5times2.mp3\",\"value\":\"10\"},{\"path\":\"2times10.mp3\",\"value\":\"20\"},{\"path\":\"5plus1.mp3\",\"value\":\"6\"}]';
            }

            data = (List<CaptchaAnswer>)JSON.deserialize(docBodyString, List<CaptchaAnswer>.Class);
            System.debug(JSON.serialize(data));
        }catch(Exception ex){
            system.debug('failed loading doc file:' + docId);
            System.debug('Detail:' + ex.getMessage());
            //data = new List<CaptchaAnswer>();
        }
        return data;
    }


    private List<CaptchaAnswer> getRandomCaptchaOptions(integer numberOfChoices, String salt) {
        List<CaptchaAnswer> options = new List<CaptchaAnswer>(images);
        options = shuffle(options);

        List<CaptchaAnswer> choices = new List<CaptchaAnswer>();
        for(integer i = 0; i < Math.Min(numberOfChoices, options.size()); i++){
            CaptchaAnswer answer = options.get(i);
            choices.add(new CaptchaAnswer(answer.getValue(), answer.getPath()));
        }

        choices = shuffle(choices);
        return choices; 
        
    }

    private CaptchaAnswer getRandomCaptchaAudio(String salt) {
        List<CaptchaAnswer> options = new List<CaptchaAnswer>(audios);
        options = shuffle(audios);
        if(options != null && options.size() > 0){
            return options.get(rand(options.size()));
        }else{
            return new CaptchaAnswer();
        }
        
    }

    /******************* Utility Methods for CAPTCHA  **********************/

    private static String hash(String somethingToHash, String salt){
        //return Hashing.md5().hashString((somethingToHash + salt), Charsets.UTF_8).toString();
        return null;
    }

    //returns a random Integer
    private static Integer rand(Integer range){
        Integer len = 5;
        String str = string.valueof(Math.abs(Crypto.getRandomInteger()));
        String randomNumber = str.substring(0, 5);
        return Math.mod(Integer.valueOf(randomNumber),range);
    }


    //https://gist.github.com/lkatney/8f7e86899a1ec7a7e4f2
    private list<CaptchaAnswer> shuffle(list<CaptchaAnswer> lst){
        if(lst != null && lst.size() > 0){
            integer currentIndex = lst.size();
            CaptchaAnswer temporaryValue;
            integer randomIndex;
            // While there remain elements to shuffle...
            while (0 != currentIndex) {
                // Pick a remaining element...
                randomIndex = integer.valueOf(Math.floor(Math.random() * currentIndex));
                currentIndex -= 1;
                // And swap it with the current element.
                temporaryValue = lst[currentIndex];
                lst[currentIndex] = lst[randomIndex];
                lst[randomIndex] = temporaryValue;

        }
        }else{
            return new List<CaptchaAnswer>();
        }
        return lst;
    }

    private static String kHexChars = '0123456789abcdef';
    public static String NewGuid() {
        String returnValue = '';
        Integer nextByte = 0;

        for (Integer i=0; i<16; i++) {

            if (i==4 || i==6 || i==8 || i==10)
                returnValue += '-';

            nextByte = (Math.round(Math.random() * 255)-128) & 255;

            if (i==6) {
                nextByte = nextByte & 15;
                nextByte = nextByte | (4 << 4);
            }

            if (i==8) {
                nextByte = nextByte & 63;
                nextByte = nextByte | 128;
            }

            returnValue += getCharAtIndex(kHexChars, nextByte >> 4);
            returnValue += getCharAtIndex(kHexChars, nextByte & 15);
        }

        return returnValue;
    }

    private static String getCharAtIndex(String str, Integer index) {

        if (str == null) return null;

        if (str.length() <= 0) return str;

        if (index == str.length()) return null;

        return str.substring(index, index+1);
    }
}