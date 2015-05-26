var guess = "";

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

function add_to_guess(number) {
  guess += number.toString();
  update_guess_code();
  
  if (guess.length == 4) {
    
    if(guess == "1234") {
      // Player won!
      flash_led("#00ff00");
      
    }else{
      // Player loss
      flash_led("#ff0000");
      show_saul();
    }
    
    // Clear string
    setTimeout(function(){
      guess = "";
      update_guess_code();
    }, 600);
    
  }
  
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
      console.log("hint");
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
    from: { x: 0, y: -500 },
    to: { x: 0, y: 0 },
    duration: 600,
    bounces: 4
  }).scale({
    from: { x: 1, y: 1 },
    to: { x: 0.1, y: 2.3 },
    duration: 800,
    easing: "sway",
    delay: 65,
    bounces: 4,
    stiffness: 2
  }).scale({
    from: { x: 1, y: 1 },
    to: { x: 5, y: 1 },
    duration: 300,
    easing: "sway",
    delay: 30,
    bounces: 4,
    stiffness: 3
  });
  
  var safe = $("#safe");
  
  safe.show();
  bounce.applyTo(safe).then(function(){
    init_buttons();
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
  bounce.applyTo(saul).then(function(){
    setTimeout(function(){
      hide_saul();
    }, 3000);
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
  bounce.applyTo(saul).then(function(){
    saul.hide();
  });
}

$(function(){
  show_logo().then(function(){
    show_safe();
    
  });
})