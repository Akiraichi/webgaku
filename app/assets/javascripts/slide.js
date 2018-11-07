$(function () {
  $('#slidelink1').on('click', function (e) {
    e.preventDefault();
    location.href = "http://localhost:3000/gallery/1";
  });

  $('#slidelink2').on('click', function (e) {
    e.preventDefault();
    location.href = "http://localhost:3000/gallery/2";
  });

  $('#slidelink3').on('click', function (e) {
    e.preventDefault();
    location.href = "http://localhost:3000/gallery/3";
  });
})

