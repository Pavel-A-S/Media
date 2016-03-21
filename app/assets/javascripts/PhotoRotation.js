function RotationListener(button_id, photo_id, object_id, direction, ImageText,
                          token, locale) {
  document.getElementById(button_id).onclick = function () {
    var photo = document.getElementById(photo_id);
    if (photo) {
      var xhr3 = new XMLHttpRequest();
      var xhr_form_3 = new FormData();

      //Temporary photo while rotation
      var photoParentNode = photo.parentNode;
      var temporaryItem = document.createElement("div");
      temporaryItem.className = "upload_InProgress";
      temporaryItem.innerHTML = "<div class = 'upload_InProgress_text'>" +
                                ImageText +
                                "</div>";
      photo.parentNode.removeChild(photo);
      photoParentNode.insertBefore(temporaryItem, photoParentNode.firstChild);

      xhr_form_3.append("rotation", direction);
      xhr3.open("PATCH", "/" + locale + "/photos/" + object_id, true);
      xhr3.setRequestHeader('X-CSRF-Token', token );
      xhr3.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
      xhr3.send(xhr_form_3);
      xhr3.onload = function() {
        temporaryItem.parentNode.removeChild(temporaryItem);
        photoParentNode.insertBefore(photo, photoParentNode.firstChild);
        photo.src = photo.src + "?" + new Date().getTime();
      }
    }
  }
}

