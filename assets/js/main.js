var guess = "";
var list_of_pressed_keys = "";

function update_guess_code() {
  if(guess.length > 4) {
    // The user too often press the buttons
    return false;
  }
  var guess_code_label = $("#safe").contents().find("#guess_x5F_code")[0];
  var guess_to_output = guess;
  while(guess_to_output.length < 4) {
    guess_to_output += "_";
  }
  guess_code_label.textContent = guess_to_output;
}

function set_available_attempts(attempts) {
  if(attempts.toString().length > 2){
    return false;
  }
  var available_attempts_label = $("#safe").contents().find("#available_x5F_attempts")[0];
  available_attempts_label.textContent = attempts;
}

function set_codebreaker_result(result){
  if(result.length > 4){
    return false;
  }
  var codebreaker_result = $("#safe").contents().find("#codebreaker_x5F_result")[0];
  codebreaker_result.textContent = result;
}

function show_jessse(){
  var jesse_video = $("#jesse_video");
  var width = $(window).width();
  var height = $(window).height();

  var logoCenterX = width/2 - 317;
  var logoCenterY = height/2 - 180;
  
  var bounce = new Bounce();
  bounce.translate({
    from: { x: -300, y: 0 },
    to: { x: logoCenterX, y: logoCenterY },
    duration: 600,
    bounces: 4
  }).scale({
    from: { x: 1.0, y: 1.0 },
    to: { x: 0.1, y: 2.3 },
    duration: 800,
    easing: "sway",
    delay: 65,
    bounces: 4
  }).scale({
    from: { x: 1.0, y: 1.0 },
    to: { x: 5.0, y: 1.0 },
    duration: 300,
    easing: "sway",
    delay: 30,
    bounces: 4
  });

  jesse_video.show();
  bounce.applyTo(jesse_video);

  // Play video
  var vid = document.getElementById("jesse_video");
  vid.play();
  
  // Hide video after 10 seconds
  setTimeout(function(){
    var bounce = new Bounce();
    bounce.translate({
      from: { x: logoCenterX, y: logoCenterY },
      to: {x: 4000, y: 0},
      duration: 600,
      bounces: 4
    });
    bounce.applyTo(jesse_video).then(function(){
      jesse_video.hide();
    });
  }, 9000);
}



function show_game_over(){
  vex.dialog.open({
    message: 'The game is over. Do you want to save your score?',
    buttons: [
      $.extend({}, vex.dialog.buttons.YES, {
        text: 'Yes'
      }), $.extend({}, vex.dialog.buttons.NO, {
        text: 'No'
      })
    ],
    callback: function(data) {
      if (data === false) {
        return start_new_game();
      }
      show_save_score_popup();
    }
  });
}

function start_new_game(){
  location.reload();
}

function show_save_score_popup(){
  vex.dialog.prompt({
    message: "Enter your name:",
    callback: function(data) {
      if(data === false){
        return start_new_game();
      }
      save_score(data);
    }
  });
}

function save_score(username){
  $.ajax({
    url: "/save/" + username,
    success: function(data) {
      show_score_table(data);
    }
  });
}

function show_score_table(collection_html){
  vex.dialog.alert({
    message: collection_html,
    callback: start_new_game
  });
}


// TODO: refactor this function
function add_to_guess(number) {
  guess += number.toString();
  update_guess_code();
  
  if (guess.length == 4) {
    
    $.ajax({
      url: "/guess/" + guess,
      success: function(data){
        set_codebreaker_result(data);

        if (data == "++++") {
          // Player won!
          flash_led("#00ff00");
          hide_safe().then(function(){
            show_jessse();
            setTimeout(function(){
              show_game_over();
            }, 9000);  
          });      
        } else if( data == "No available attempts.") {
          flash_led("#ff0000");
          hide_safe().then(function(){
            show_saul().then(function(){
              show_game_over();
            }); 
          });          
        } else {
          flash_led("#ff0000");
        }

        // Clear string
        setTimeout(function(){
          guess = "";
          update_guess_code();
        }, 600);

      }
    });
    
  }
  
}

function show_hint(){
  $.ajax({
    url: "/hint",
    success: function(data){
      set_codebreaker_result(data);
    }
  })
}

function init_buttons(){
  var buttons = $("#safe").contents().find('[id^="button"]');
  
  // Set buttons styles
  buttons.css("cursor", "pointer");
  buttons.css("display", "block");
  
  buttons.on("click", function(o){
    var buttonId = $(this).attr("id");
    
    if (/[\d]$/.test(buttonId)) {
      buttonNumber = buttonId.slice(-1);
      add_to_guess(buttonNumber);
    }else{
      // Seems hint button was pressed
      show_hint();
    }
    
  });
}

function flash_led(color) {
  var led = $("#safe").contents().find('#led');
  var defaultColor = led.attr("fill");
  
  led.attr("fill", color);
  setTimeout(function(){
    led.attr("fill", defaultColor);
  }, 1000);
}

function show_logo() {
  
  var width = $(window).width();
  var height = $(window).height();
  
  var logoCenterX = width/2 - 191;
  var logoCenterY = height/2 - 27;
  
  var bounce = new Bounce();
  bounce.translate({
    from: { x: 0, y: 0 },
    to: { x: logoCenterX, y: logoCenterY },
    duration: 1,
    bounces: 0
  }).scale({
    from: { x: 0.1, y: 0.1 },
    to: { x: 1.0, y: 1.0 },
    duration: 2000,
    bounces: 3
  }).translate({
    from: { x: 0, y: 0 },
    to: { x: -logoCenterX, y: -logoCenterY },
    duration: 2000,
    delay: 2000,
    bounces: 3
  }).scale({
    from: { x: 1, y: 1 },
    to: { x: 0.7, y: 0.7 },
    duration: 2000,
    delay: 2000,
    bounces: 10
  });
  
  var logo = $("#logo");
  logo.show();
  return bounce.applyTo(logo);
}

function show_safe() {
  var bounce = new Bounce();
  bounce.translate({
    from: { x: -500, y: 0 },
    to: { x: 0, y: 0 },
    duration: 600,
    bounces: 8
  });
  
  var safe = $("#safe");
  
  safe.show();
  return bounce.applyTo(safe).then(function(){
    init_buttons();
  });
}

function hide_safe(){
  var bounce = new Bounce();
  bounce.translate({
    from: { x: 0, y: 0 },
    to: { x: 2000, y: 0 },
    duration: 600,
    bounces: 8
  });
  
  var safe = $("#safe");
    
  return bounce.applyTo(safe).then(function(){
    safe.hide();
  });
}

function show_saul() {
  var bounce = new Bounce();
  bounce.translate({
    from: { x: 250, y: 0 },
    to: { x: 0, y: 0 },
    duration: 1000,
    bounces: 5
  });
  var saul = $("#saul");
  saul.show();
  return bounce.applyTo(saul).then(function(){
    setTimeout(function(){
      hide_saul();
    }, 4000);
  });
}

function use_cheat(){
  $.ajax({
      url: "/cheat",
      success: function(data){
        set_codebreaker_result(data);
      }
  });
}

function hide_saul() {
  var bounce = new Bounce();
  bounce.translate({
    from: { x: 0, y: 0 },
    to: { x: 250, y: 0 },
    duration: 1000,
    bounces: 0
  });
  var saul = $("#saul");
  return bounce.applyTo(saul).then(function(){
    saul.hide();
  });
}

// For cheat
$(document).on("keypress", function (e) {
  var key = String.fromCharCode(e.which);
  list_of_pressed_keys += key;
  if (/iddqd/.test(list_of_pressed_keys)){
    use_cheat();
    list_of_pressed_keys = "";
  }else if(/[1-6]/.test(key)){
    add_to_guess(key);
  }
});

$(function(){

  show_logo().then(function(){
    show_safe();    
  });

})