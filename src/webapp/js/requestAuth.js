$(document).ready( function() {
   
    $("#requestAuth").submit(function(){
        var rc = validateForm();
        return rc;
     });
        
    function validateForm(){
       var checkboxes = $("input[type='checkbox']");
       
       if (!checkboxes.is(":checked")){
           $("#requestAuth").after('<span class="error" style="color:red"> At least one contribution must be checked</span>')
           return false;
       }
 
     }
});
