// base attributes for all color boxes 
var colorboxAttrs = {
  height:"50%", 
  inline:true, 
  opacity:0.5 ,
  width:"85%", 
};

$(document).ready( 
  function() {
    // load up posts -- get this running first 
    load_posts();

    //// countdown timer
    // hide it by default
    $("#countdown").hide();

    // and fade it in and out when hovering over the app-name and icon-bar divs
    $("#app-name").hover(
      function () { $("#countdown").fadeIn() } ,
      function () { $("#countdown").fadeOut() }
    );
    $("#icon-bar").hover(
      function () { $("#countdown").fadeIn() } ,
      function () { $("#countdown").fadeOut() }
    );

    // set up the update form to post over AJAX and get responses as JSON
    $("#update-form").ajaxForm({ dataType: 'json' , success: showResponse });

    // set up the colorbox attached to the debug_btn
    var debug_colorboxAttrs = colorboxAttrs;
    debug_colorboxAttrs['href'] = "#debug_info";
    debug_colorboxAttrs['onComplete'] = function(){
      date = new Date();
      epoch = Math.round(date.getTime() / 1000);
      $("#current_epoch").text( epoch );
    };
    $("#debug_btn").colorbox( debug_colorboxAttrs );

    // set up the colorbox attached to the post_btn
    var post_colorboxAttrs = colorboxAttrs;
    post_colorboxAttrs['href'] = "#update-form-div";
    post_colorboxAttrs['onComplete'] = function(){
      $(".accounts").removeAttr('disabled');
      $(".accounts").val([]);
      $("#in_reply_to").val();
      $("#status").val('');
      $("#status").focus();
      $("#update-form-output").html('');
    };
    $("#post_btn").colorbox( post_colorboxAttrs );

    // set up the reload btn so that it calls load_posts if clicked
    // and auto-calls load_posts every 300 seconds
    // ###FIXME figure out a way to make this a configurable pref... 
    $("#reload_btn").click(function() { load_posts() });
    $("#reload_btn").everyTime( '300s' , function() { load_posts() });

    // set up the clear btn to clean out the 'posts' div
    $("#clear_btn").click( function() { $("#posts").html('') });
  }
);

// load up a new set of posts and append them to the 'posts' div
function load_posts (force) {
  // default force to 0 if it's not set 
  force = typeof(force) != 'undefined' ? force : 0;

  $.get('/new_posts/' + force ,
        function( data ) {
          $("#countdown").countdown('destroy');
          $("#posts").append(data) ;
          $("#countdown").countdown({ until: +300 , compact: true , layout: 'Reload in {mnn}{sep}{snn}' });
        });
}

// handle the reply btns 
function reply( account, author, id ) {
  var account_id = "#accounts\\." + account;
  // set up the attributes for the color box attached to reply btns    
  var reply_colorboxAttrs = colorboxAttrs;
  reply_colorboxAttrs['href'] = "#update-form-div";
  reply_colorboxAttrs['onComplete'] = function(){
    $(".accounts").attr('disabled',true);
    $(account_id).removeAttr('disabled');
    $(".accounts").val([account]);
    $("#in_reply_to").val(id);
    $("#status").val( author );
    $("#status").focus();
    $("#update-form-output").html('');
  };
  $.fn.colorbox( reply_colorboxAttrs );
  return true;
}

function showResponse(data)  {
  $("#update-form-output").html( data.message );
  if( data.success ) {
    setTimeout(function() { $("#post_btn").colorbox.close() } , 2000 );
    load_posts(1);
  }
  else { window.alert( data.message ); }
}
