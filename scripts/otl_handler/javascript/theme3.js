$(document).ready(function(){

    // append content div
    $("body").prepend("<div id=\"content\">test</div>");
    $("#content").hide();

    // FIXME  - document.width + document.height
    $(".outline").click(function(){
        $("#content").html( $(this).html() );
        $("body").background("#7b7c8c");
        $("#content").show();
    });

    $("#content").click(function(){
        $(this).hide();
        $("body").background("#acadc3");
    });

    // re-activate links (the event is stomped on by the li event)
    $(".outline a").click(function(){ window.location.href = this; return false; });

});
