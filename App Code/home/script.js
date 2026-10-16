/* financeBI homepage interactions: responsive navigation and accessible motion */
(() => {
  const menuButton = document.querySelector('.menu-toggle');
  const nav = document.querySelector('#primary-nav');
  const dropdown = document.querySelector('.dropdown');
  const dropdownToggle = document.querySelector('.dropdown-toggle');

  if (menuButton && nav) {
    menuButton.addEventListener('click', () => {
      const open = nav.classList.toggle('is-open');
      menuButton.setAttribute('aria-expanded', String(open));
      menuButton.setAttribute('aria-label', open ? 'Close navigation' : 'Open navigation');
    });

    nav.querySelectorAll('a').forEach((link) => {
      link.addEventListener('click', () => {
        if (window.matchMedia('(max-width: 760px)').matches && !link.classList.contains('dropdown-toggle')) {
          nav.classList.remove('is-open');
          menuButton.setAttribute('aria-expanded', 'false');
          menuButton.setAttribute('aria-label', 'Open navigation');
        }
      });
    });
  }

  if (dropdown && dropdownToggle) {
    dropdownToggle.addEventListener('click', (event) => {
      if (window.matchMedia('(max-width: 760px)').matches) {
        event.preventDefault();
        const open = dropdown.classList.toggle('open');
        dropdownToggle.setAttribute('aria-expanded', String(open));
      }
    });
  }

  window.addEventListener('resize', () => {
    if (window.innerWidth > 760 && nav && menuButton) {
      nav.classList.remove('is-open');
      menuButton.setAttribute('aria-expanded', 'false');
      if (dropdown && dropdownToggle) {
        dropdown.classList.remove('open');
        dropdownToggle.setAttribute('aria-expanded', 'false');
      }
    }
  });
})();
