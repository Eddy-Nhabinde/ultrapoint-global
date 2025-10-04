document.addEventListener('DOMContentLoaded', () => {

  const lazyLoadImages = () => {
    const images = document.querySelectorAll('img[data-src]');
    const imageObserver = new IntersectionObserver((entries, observer) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const img = entry.target;
          img.src = img.dataset.src;
          img.removeAttribute('data-src');
          observer.unobserve(img);
        }
      });
    });

    images.forEach(img => imageObserver.observe(img));
  };

  const smoothScrollLinks = () => {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
      anchor.addEventListener('click', function (e) {
        const href = this.getAttribute('href');
        if (href !== '#' && document.querySelector(href)) {
          e.preventDefault();
          document.querySelector(href).scrollIntoView({
            behavior: 'smooth',
            block: 'start'
          });
        }
      });
    });
  };

  const enhanceAccessibility = () => {
    const buttons = document.querySelectorAll('a[class*="btn"]');
    buttons.forEach(button => {
      if (!button.getAttribute('role')) {
        button.setAttribute('role', 'button');
      }
      if (!button.getAttribute('aria-label') && button.textContent) {
        button.setAttribute('aria-label', button.textContent.trim());
      }
    });

    const links = document.querySelectorAll('a[target="_blank"]');
    links.forEach(link => {
      if (!link.getAttribute('rel')) {
        link.setAttribute('rel', 'noopener noreferrer');
      }
    });

    const images = document.querySelectorAll('img:not([alt])');
    images.forEach(img => {
      img.setAttribute('alt', '');
    });
  };

  const debounce = (func, wait) => {
    let timeout;
    return function executedFunction(...args) {
      const later = () => {
        clearTimeout(timeout);
        func(...args);
      };
      clearTimeout(timeout);
      timeout = setTimeout(later, wait);
    };
  };

  const handleScrollPerformance = () => {
    let ticking = false;
    const scrollHandler = () => {
      if (!ticking) {
        window.requestAnimationFrame(() => {
          const scrolled = window.pageYOffset;
          const header = document.querySelector('.main_menu');
          if (header) {
            if (scrolled > 50) {
              header.classList.add('menu_fixed', 'animated', 'fadeInDown');
            } else {
              header.classList.remove('menu_fixed', 'animated', 'fadeInDown');
            }
          }
          ticking = false;
        });
        ticking = true;
      }
    };

    window.addEventListener('scroll', scrollHandler, { passive: true });
  };

  const addLoadingStates = () => {
    const forms = document.querySelectorAll('form');
    forms.forEach(form => {
      form.addEventListener('submit', function(e) {
        const submitButton = this.querySelector('[type="submit"], .regerv_btn_iner');
        if (submitButton) {
          submitButton.classList.add('loading');
          submitButton.style.opacity = '0.7';
          submitButton.style.pointerEvents = 'none';
        }
      });
    });
  };

  const prefetchLinks = () => {
    const links = document.querySelectorAll('a[href$=".html"]');
    const linkObserver = new IntersectionObserver((entries) => {
      entries.forEach(entry => {
        if (entry.isIntersecting) {
          const link = entry.target;
          const href = link.getAttribute('href');
          if (href && !link.dataset.prefetched) {
            const prefetchLink = document.createElement('link');
            prefetchLink.rel = 'prefetch';
            prefetchLink.href = href;
            document.head.appendChild(prefetchLink);
            link.dataset.prefetched = 'true';
          }
        }
      });
    });

    links.forEach(link => linkObserver.observe(link));
  };

  const initKeyboardNavigation = () => {
    document.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') {
        const modal = document.querySelector('.modal.show, .popup-visible');
        if (modal) {
          modal.classList.remove('show', 'popup-visible');
        }
      }
    });

    const focusableElements = document.querySelectorAll(
      'a, button, input, textarea, select, [tabindex]:not([tabindex="-1"])'
    );
    focusableElements.forEach((element, index) => {
      if (!element.hasAttribute('tabindex')) {
        element.setAttribute('tabindex', '0');
      }
    });
  };

  const addFocusStyles = () => {
    let isMouseUser = false;

    document.addEventListener('mousedown', () => {
      isMouseUser = true;
    });

    document.addEventListener('keydown', (e) => {
      if (e.key === 'Tab') {
        isMouseUser = false;
      }
    });

    document.addEventListener('focusin', (e) => {
      if (!isMouseUser) {
        e.target.classList.add('keyboard-focus');
      }
    });

    document.addEventListener('focusout', (e) => {
      e.target.classList.remove('keyboard-focus');
    });
  };

  lazyLoadImages();
  smoothScrollLinks();
  enhanceAccessibility();
  handleScrollPerformance();
  addLoadingStates();
  prefetchLinks();
  initKeyboardNavigation();
  addFocusStyles();

  if ('serviceWorker' in navigator && location.hostname !== 'localhost') {
    window.addEventListener('load', () => {
      navigator.serviceWorker.register('/sw.js').catch(() => {});
    });
  }
});

window.addEventListener('load', () => {
  document.body.classList.add('page-loaded');
});
