//それぞれのスライドショーを作った
$(function () {
  //各種スライドショーでクリックした際のリンク先の修正
  $('#slidelink1').on('click', function (e) {
    e.preventDefault();
    location.href = "/gallery/1";
  });

  $('#slidelink2').on('click', function (e) {
    e.preventDefault();
    location.href = "/gallery/2";
  });

  $('#slidelink3').on('click', function (e) {
    e.preventDefault();
    location.href = "/gallery/3";
  });
})
