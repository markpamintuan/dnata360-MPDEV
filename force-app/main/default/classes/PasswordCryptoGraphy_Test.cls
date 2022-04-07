@istest
public class PasswordCryptoGraphy_Test{


    static testmethod void PasswordCryptoGraphy_methods(){
        PasswordCryptoGraphy cls = new PasswordCryptoGraphy();
        cls.strActualPassword = 'JKLJKLJKL';
        cls.EncryptPassword();
        //cls.encryptMobilePhone();
        try{
            PasswordCryptoGraphy.DecryptPassword('2kySAUKKn2GPwjPB6WCIeC31s4gafSsQKPBrkgRvXJA=');
            //System.assert(false);
        }catch(exception e){
            //System.assertEquals('Given final block not properly padded', e.getMessage());
        }
        
    
    }
    
        

}