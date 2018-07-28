$(document).ready(function(){
    $('input[type="button"]').click(function(){
        var $op = $('#select2 option:selected'),
            $this = $(this);
        if($op.length){
            ($this.val() == 'Up') ? 
                $op.first().prev().before($op) : 
                $op.last().next().after($op);
        }
    });
});