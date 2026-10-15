// script.js

let currentIndex = 0;
const track = document.querySelector('.banner-track');
const totalSlides = document.querySelectorAll('.banner-image').length;

setInterval(() => {
  currentIndex = (currentIndex + 1) % totalSlides;
  track.style.transform = `translateX(-${currentIndex * 626}px)`;
}, 10000); // 10 seconds display time
