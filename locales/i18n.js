class SimpleI18n {
    constructor() {
        this.currentLang = localStorage.getItem('lang') || 'pt';
        this.translations = {};
        this.loadTranslations(this.currentLang);
        this.initLanguageSelector();
    }

    async loadTranslations(lang) {
        try {
            const response = await fetch(`locales/${lang}.json`);
            this.translations = await response.json();
            this.applyTranslations();
            document.documentElement.lang = lang;
            localStorage.setItem('lang', lang);
        } catch (err) {
            console.error('Erro ao carregar tradução:', err);
        }
    }

    applyTranslations() {
        document.querySelectorAll('[data-i18n]').forEach(element => {
            const key = element.getAttribute('data-i18n');
            if (this.translations[key]) {
                // Para title da página
                if (element.tagName === 'TITLE') {
                    document.title = this.translations[key];
                } else {
                    element.textContent = this.translations[key];
                }
            }
        });

        // Atualiza placeholder, alt, etc (opcional)
        document.querySelectorAll('[data-i18n-placeholder]').forEach(el => {
            const key = el.getAttribute('data-i18n-placeholder');
            if (this.translations[key]) el.placeholder = this.translations[key];
        });
    }

    initLanguageSelector() {
        const select = document.getElementById('language-select');

        if (select) {
            select.value = this.currentLang;
            select.addEventListener('change', (e) => {
                this.loadTranslations(e.target.value);
            });
        }
        if (!localStorage.getItem('lang')) {
            const browserLang = navigator.language || navigator.userLanguage;
            const shortLang = browserLang.substr(0, 2);
            if (['en', 'es', 'fr', 'pt'].includes(shortLang)) {
                this.loadTranslations(shortLang);
            }
        }
    }
}

// Inicia o sistema
document.addEventListener('DOMContentLoaded', () => {
    new SimpleI18n();
});


function changeLanguage(lang) {
    localStorage.setItem('lang', lang);

    fetch(`locales/${lang}.json?t=${Date.now()}`)
        .then(r => r.json())
        .then(data => {
            document.querySelectorAll('[data-i18n]').forEach(el => {
                const key = el.getAttribute('data-i18n');
                if (data[key] !== undefined) {
                    if (el.tagName === 'TITLE') {
                        document.title = data[key];
                    } else {
                        el.textContent = data[key];
                    }
                }
            });

            document.documentElement.lang = lang;
            const select = document.getElementById('language-select');
            if (select) select.value = lang;
        })
        .catch(err => console.error('Erro ao carregar idioma:', err));
}

document.addEventListener('DOMContentLoaded', () => {
    const savedLang = localStorage.getItem('lang') || 'pt';
    document.getElementById('language-select').value = savedLang;
    changeLanguage(savedLang);
});

document.addEventListener('DOMContentLoaded', () => {
    const year = new Date().getFullYear();
    document.querySelectorAll('[data-i18n="copyright"]').forEach(el => {
        el.innerHTML = i18next.t('copyright', { year: year });
    });
});