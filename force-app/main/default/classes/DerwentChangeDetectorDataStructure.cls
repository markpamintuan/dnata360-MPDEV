global class DerwentChangeDetectorDataStructure {

    global class Response{
        
        //Do Not change these parameters without consulting with TR team.
        global Boolean success;
        global String message;
        


        global Response(Boolean success, String msg){
            this.message = msg;
            this.success = success;
        }
    }

}