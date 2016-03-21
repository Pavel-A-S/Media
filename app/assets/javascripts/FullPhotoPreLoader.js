function FullPhotoPreLoader(src, photoBlockId, ImageText) {

  var photoBlock = document.getElementById(photoBlockId);
  var temporaryItem = document.createElement("div");
  temporaryItem.className = "upload_InProgress";
  temporaryItem.innerHTML = "<div class = 'upload_InProgress_text'>" +
                            ImageText +
                            "</div>";
  photoBlock.appendChild(temporaryItem);

  var photo = document.createElement("img");
  photo.className = "full_photo";
  photo.addEventListener("load", showPhoto);
  photo.src = src;

  function showPhoto() {
    temporaryItem.parentNode.removeChild(temporaryItem);
    photoBlock.appendChild(photo);
  }
}

