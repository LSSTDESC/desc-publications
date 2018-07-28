$(document).ready(function(){
    
    $('#myTextBox').on('change', function(){

        var $select = "";
        var textBoxValue = $(this).val();

        $('#mySelect option').filter(function(){
            return this.innerHTML.indexOf(textBoxValue) == 0;
        })
            .remove()
            .prependTo($('#mySelect'));
    });

});