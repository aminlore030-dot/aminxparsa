// Amin Forex - Main JavaScript
// Handles data loading, search, filtering, and dynamic content

const SITE_CONFIG = {
    name: 'امین فارکس',
    tagline: 'دانلود رایگان اندیکاتورهای MetaTrader 5',
    description: 'دانلود رایگان اندیکاتورهای MetaTrader 5 با فایل اصلی MQL5 در سایت امین فارکس.',
    url: window.location.origin
};

// Cache for indicators data
let indicatorsCache = null;

/**
 * Load indicators data from JSON
 */
async function loadIndicators() {
    if (indicatorsCache) return indicatorsCache;
    try {
        const response = await fetch('data/indicators.json');
        if (!response.ok) throw new Error('Failed to load data');
        const data = await response.json();
        indicatorsCache = data.indicators || [];
        return indicatorsCache;
    } catch (error) {
        console.error('Error loading indicators:', error);
        return [];
    }
}

/**
 * Get query parameter
 */
function getQueryParam(name) {
    const url = new URL(window.location.href);
    return url.searchParams.get(name);
}

/**
 * Generate slug from filename
 */
function getIndicatorSlug(filename) {
    return filename.replace('.mq5', '');
}

/**
 * Get detail page URL for an indicator
 */
function getDetailUrl(filename) {
    return `indicator.html?id=${encodeURIComponent(filename)}`;
}

/**
 * Render indicator card
 */
function renderCard(indicator, options = {}) {
    const { showDownload = true, animationDelay = 0 } = options;

    const card = document.createElement('article');
    card.className = 'indicator-card';
    card.dataset.id = indicator.id;
    card.dataset.category = indicator.category;
    card.dataset.filename = indicator.filename;
    card.dataset.title = indicator.title;
    if (animationDelay) {
        card.style.animationDelay = `${animationDelay}ms`;
    }

    const cardImage = `
        <div class="card-image">
            <img src="images/${indicator.image}" alt="${indicator.title}" loading="lazy" onerror="this.parentElement.innerHTML='<div style=\\'display:flex;align-items:center;justify-content:center;height:100%;color:#64748b;font-size:3rem\\'>📊</div>'">
            <span class="card-badge">MQ5</span>
        </div>
    `;

    const cardContent = `
        <div class="card-content">
            <h3 class="card-title">${indicator.title}</h3>
            <p class="card-title-en">${indicator.titleEn}</p>
            <p class="card-description">${indicator.shortDescription}</p>
            <div class="card-meta">
                <span class="meta-tag">${indicator.categoryLabel}</span>
                <span class="meta-tag format">فرمت MQ5</span>
            </div>
            <div class="card-actions">
                <a href="${getDetailUrl(indicator.filename)}" class="btn btn-ghost">مشاهده جزئیات</a>
                ${showDownload ? `
                    <a href="${indicator.downloadPath}" class="btn btn-primary" download>
                        ⬇ دانلود رایگان
                    </a>
                ` : ''}
            </div>
        </div>
    `;

    card.innerHTML = cardImage + cardContent;
    return card;
}

/**
 * Render indicators grid
 */
async function renderIndicatorsGrid(container, options = {}) {
    const { filter = '', search = '', category = 'all' } = options;
    const indicators = await loadIndicators();

    if (!container) return;

    container.innerHTML = '';

    let filtered = indicators;

    // Apply search filter
    if (search) {
        const searchLower = search.toLowerCase();
        filtered = filtered.filter(ind =>
            ind.title.toLowerCase().includes(searchLower) ||
            ind.titleEn.toLowerCase().includes(searchLower) ||
            ind.shortDescription.toLowerCase().includes(searchLower) ||
            ind.categoryLabel.toLowerCase().includes(searchLower)
        );
    }

    // Apply category filter
    if (category && category !== 'all') {
        filtered = filtered.filter(ind => ind.category === category);
    }

    if (filtered.length === 0) {
        container.innerHTML = `
            <div class="empty-state" style="grid-column: 1/-1;">
                <div class="icon">🔍</div>
                <h3>نتیجه‌ای یافت نشد</h3>
                <p>لطفاً عبارت جستجوی دیگری را امتحان کنید.</p>
            </div>
        `;
        return;
    }

    filtered.forEach((ind, i) => {
        const card = renderCard(ind, { animationDelay: i * 50 });
        container.appendChild(card);
    });

    // Update count if there's a counter
    updateCounter(filtered.length, indicators.length);
}

/**
 * Update counter
 */
function updateCounter(visible, total) {
    const counter = document.getElementById('indicators-count');
    const totalCounter = document.getElementById('indicators-total');
    if (counter) counter.textContent = visible;
    if (totalCounter) totalCounter.textContent = total;
}

/**
 * Render categories filter
 */
async function renderCategories(container) {
    const indicators = await loadIndicators();
    if (!container) return;

    const categories = new Map();
    indicators.forEach(ind => {
        if (!categories.has(ind.category)) {
            categories.set(ind.category, ind.categoryLabel);
        }
    });

    container.innerHTML = '';

    const allPill = document.createElement('button');
    allPill.className = 'filter-pill active';
    allPill.dataset.category = 'all';
    allPill.textContent = 'همه';
    container.appendChild(allPill);

    categories.forEach((label, value) => {
        const pill = document.createElement('button');
        pill.className = 'filter-pill';
        pill.dataset.category = value;
        pill.textContent = label;
        container.appendChild(pill);
    });

    // Set up click handlers
    container.querySelectorAll('.filter-pill').forEach(pill => {
        pill.addEventListener('click', () => {
            container.querySelectorAll('.filter-pill').forEach(p => p.classList.remove('active'));
            pill.classList.add('active');

            const category = pill.dataset.category;
            const searchInput = document.getElementById('search-input');
            const search = searchInput ? searchInput.value : '';
            const grid = document.getElementById('indicators-grid');

            if (grid) {
                renderIndicatorsGrid(grid, { search, category });
            }
        });
    });
}

/**
 * Initialize search
 */
function initSearch(inputId, gridId) {
    const input = document.getElementById(inputId);
    const grid = document.getElementById(gridId);
    if (!input || !grid) return;

    let timer;
    input.addEventListener('input', (e) => {
        clearTimeout(timer);
        timer = setTimeout(() => {
            const activePill = document.querySelector('.filter-pill.active');
            const category = activePill ? activePill.dataset.category : 'all';
            renderIndicatorsGrid(grid, {
                search: e.target.value.trim(),
                category
            });
        }, 200);
    });
}

/**
 * Render indicator detail page
 */
async function renderIndicatorDetail() {
    const container = document.getElementById('indicator-detail');
    if (!container) return;

    const id = getQueryParam('id');
    if (!id) {
        container.innerHTML = '<div class="empty-state"><h3>اندیکاتور یافت نشد</h3></div>';
        return;
    }

    const indicators = await loadIndicators();
    const indicator = indicators.find(ind => ind.filename === id);

    if (!indicator) {
        container.innerHTML = '<div class="empty-state"><h3>اندیکاتور یافت نشد</h3><p>فایل مورد نظر وجود ندارد.</p></div>';
        return;
    }

    // Update page title and meta
    document.title = `${indicator.title} | ${SITE_CONFIG.name}`;
    const metaDesc = document.querySelector('meta[name="description"]');
    if (metaDesc) {
        metaDesc.setAttribute('content', `${indicator.shortDescription} - ${SITE_CONFIG.name}`);
    }

    // Render content
    container.innerHTML = `
        <a href="indicators.html" class="detail-back">← بازگشت به لیست اندیکاتورها</a>

        <div class="detail-header fade-in">
            <div class="detail-grid">
                <div class="detail-image">
                    <img src="images/${indicator.image}" alt="${indicator.title}" onerror="this.parentElement.innerHTML='<div style=\\'display:flex;align-items:center;justify-content:center;height:100%;color:#64748b;font-size:5rem\\'>📊</div>'">
                </div>
                <div class="detail-info">
                    <div class="detail-tags">
                        <span class="meta-tag">${indicator.categoryLabel}</span>
                        <span class="meta-tag format">فرمت MQ5</span>
                        <span class="meta-tag">رایگان</span>
                    </div>
                    <h1>${indicator.title}</h1>
                    <p class="subtitle">${indicator.titleEn}</p>
                    <p class="description">${indicator.description}</p>
                    <a href="${indicator.downloadPath}" class="detail-download" download>
                        ⬇ دانلود رایگان MQ5
                    </a>
                </div>
            </div>
        </div>

        ${indicator.features && indicator.features.length ? `
        <section class="detail-section">
            <h2>قابلیت‌ها</h2>
            <ul class="features-list">
                ${indicator.features.map(f => `<li>${f}</li>`).join('')}
            </ul>
        </section>
        ` : ''}

        ${indicator.inputs && indicator.inputs.length ? `
        <section class="detail-section">
            <h2>پارامترهای ورودی</h2>
            <table class="info-table">
                <tbody>
                    ${indicator.inputs.map(inp => `
                        <tr>
                            <th>${inp.label || inp.name}</th>
                            <td><code>${inp.name}</code></td>
                            <td>پیش‌فرض: <code>${inp.default}</code></td>
                        </tr>
                    `).join('')}
                </tbody>
            </table>
        </section>
        ` : ''}

        <section class="detail-section">
            <h2>اطلاعات فایل</h2>
            <table class="info-table">
                <tbody>
                    <tr>
                        <th>نام فایل</th>
                        <td><code>${indicator.filename}</code></td>
                    </tr>
                    <tr>
                        <th>پلتفرم</th>
                        <td>MetaTrader 5</td>
                    </tr>
                    <tr>
                        <th>فرمت</th>
                        <td>MQ5</td>
                    </tr>
                    <tr>
                        <th>نوع</th>
                        <td>Indicator</td>
                    </tr>
                    <tr>
                        <th>دسته‌بندی</th>
                        <td>${indicator.categoryLabel}</td>
                    </tr>
                    <tr>
                        <th>لایسنس</th>
                        <td>رایگان</td>
                    </tr>
                    <tr>
                        <th>زبان</th>
                        <td>MQL5</td>
                    </tr>
                </tbody>
            </table>
        </section>

        <section class="detail-section">
            <h2>نحوه استفاده</h2>
            <p style="color: var(--text-secondary); line-height: 1.9; margin-bottom: 1rem;">
                برای استفاده از این اندیکاتور در MetaTrader 5 مراحل زیر را دنبال کنید:
            </p>
            <ol class="features-list" style="list-style: none; counter-reset: step;">
                <li>فایل <code>${indicator.filename}</code> را دانلود کنید.</li>
                <li>متاتریدر ۵ را باز کنید.</li>
                <li>از منوی File گزینه Open Data Folder را انتخاب کنید.</li>
                <li>به پوشه MQL5 سپس Indicators بروید.</li>
                <li>فایل دانلود شده را در این پوشه کپی کنید.</li>
                <li>متاتریدر را مجدداً راه‌اندازی کنید یا Navigator را Refresh کنید.</li>
                <li>از پنل Navigator اندیکاتور را روی نمودار مورد نظر بکشید.</li>
            </ol>
        </section>

        <div style="text-align: center; margin-top: 2rem;">
            <a href="${indicator.downloadPath}" class="btn-download" download>
                ⬇ دانلود رایگان MQ5
            </a>
        </div>
    `;
}

/**
 * Initialize home page
 */
async function initHomePage() {
    const indicators = await loadIndicators();
    const counter = document.getElementById('hero-count');
    if (counter) {
        counter.textContent = indicators.length;
    }

    const totalCounter = document.getElementById('hero-categories');
    if (totalCounter) {
        const categories = new Set(indicators.map(i => i.category));
        totalCounter.textContent = categories.size;
    }

    // Show featured indicators (first 6)
    const featuredGrid = document.getElementById('featured-grid');
    if (featuredGrid) {
        indicators.slice(0, 6).forEach((ind, i) => {
            const card = renderCard(ind, { animationDelay: i * 80 });
            featuredGrid.appendChild(card);
        });
    }
}

/**
 * Mobile menu toggle
 */
function initMobileMenu() {
    const toggle = document.querySelector('.menu-toggle');
    const nav = document.querySelector('.nav');
    if (toggle && nav) {
        toggle.addEventListener('click', () => {
            nav.classList.toggle('open');
        });
    }
}

/**
 * Mark active nav link
 */
function setActiveNav() {
    const path = window.location.pathname.split('/').pop() || 'index.html';
    document.querySelectorAll('.nav-link').forEach(link => {
        const href = link.getAttribute('href');
        if (href === path || (path === '' && href === 'index.html')) {
            link.classList.add('active');
        }
    });
}

// Initialize on DOM ready
document.addEventListener('DOMContentLoaded', () => {
    initMobileMenu();
    setActiveNav();

    // Home page
    if (document.getElementById('featured-grid')) {
        initHomePage();
    }

    // Indicators listing page
    if (document.getElementById('indicators-grid')) {
        renderCategories(document.getElementById('filter-pills'));
        renderIndicatorsGrid(document.getElementById('indicators-grid'));
        initSearch('search-input', 'indicators-grid');
    }

    // Detail page
    if (document.getElementById('indicator-detail')) {
        renderIndicatorDetail();
    }
});