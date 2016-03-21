// comment_text_area and comment_button_submit are necessary
function EnterSubmitComments() {

  var input = document.getElementById('comment_text_area');
  var chatButton = document.getElementById('comment_button_submit');

  if (input && chatButton) {
    input.addEventListener('keypress', function (pressedButton){
        createSendEvent(pressedButton, chatButton, this);
    }, false)
  }

  function createSendEvent(pressedButton, chatButton, input) {
    if (pressedButton.keyCode == 13 && !pressedButton.shiftKey) {
      chatButton.click();
      input.value = "";
    }
  }
}
