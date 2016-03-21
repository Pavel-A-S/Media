// chat_text and ChatButton are necessary
function EnterSubmitChat() {

  var input = document.getElementById('chat_text');
  var chatButton = document.getElementById('ChatButton');

  if (input && chatButton) {
    input.addEventListener('keypress', function (pressedButton){
        createSendEvent(pressedButton, chatButton);
    }, false)
  }

  function createSendEvent(pressedButton, chatButton) {
    if (pressedButton.keyCode == 13 && !pressedButton.shiftKey) {
      var event = document.createEvent('Event');
      event.initEvent('click', true, true);
      chatButton.dispatchEvent(event);
    }
  }
}

