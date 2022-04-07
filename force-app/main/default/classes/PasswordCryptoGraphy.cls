Global without Sharing Class PasswordCryptoGraphy{

    public string strActualPassword{get;set;}
    public string strResult{get;set;}
    public string strKey;

    public PasswordCryptoGraphy() {
        strActualPassword = '';
        strResult = '';
        strKey = 'U8907654HG0765835671KLM67BTSRA12';
    }
   
    // Method to EncryptPassword
    public void EncryptPassword(){
        if(strActualPassword!=null && strActualPassword!=''){
            Blob keyblobval = Blob.valueOf(strKey);
            Blob EncryptedPasswordBlob = Crypto.encryptWithManagedIV('AES256', keyblobval, Blob.valueOf(strActualPassword));
            String strEncryptedPasswordText = EncodingUtil.base64Encode(EncryptedPasswordBlob); 
            System.debug('strEncryptedPasswordText==>'+strEncryptedPasswordText);
            strResult = strEncryptedPasswordText;
         }
    }
    
    // Method to DecryptPassword
    
    Global static string DecryptPassword(string encryptedString){
        
        string strKey = 'U8907654HG0765835671KLM67BTSRA12';
        string decryptedTxt;
        Blob keyblobval = Blob.valueOf(strKey);
       // System.debug('strActualPassword==>'+strActualPassword);
        Blob encodedEncryptedBlob = EncodingUtil.base64Decode(encryptedString);
        Blob decryptedBlob = Crypto.decryptWithManagedIV('AES256', keyblobval, encodedEncryptedBlob);
        String decryptedPasswordText = decryptedBlob.toString();
        System.debug('decryptedPasswordText==>'+decryptedPasswordText);
        decryptedTxt = decryptedPasswordText;
        system.debug('PWD******'+decryptedTxt); 
        return decryptedTxt;
        
    }
    
    
   
}