function PreLoader(ClassName) {

  var photos = document.getElementsByClassName(ClassName);
  for (var i = 0; i < photos.length; i++) {
    photos[i].style.visibility = "hidden";
    photos[i].addEventListener("load", showPhoto);
  }

  function showPhoto() {
    this.style.visibility = "visible";
  }
}

