/* Standalone design prototype. No API, authentication or production writes. */
"use strict";
const $ = (s, root = document) => root.querySelector(s);
const $$ = (s, root = document) => [...root.querySelectorAll(s)];
const esc = (value) =>
  String(value ?? "").replace(
    /[&<>"']/g,
    (c) =>
      ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[
        c
      ],
  );
const icon = (name) => `<i data-lucide="${name}" aria-hidden="true"></i>`;
const btn = (label, action, symbol = "", style = "") =>
  `<button class="button ${style}" data-action="${action}">${symbol ? icon(symbol) : ""}${label}</button>`;
const link = (label, route, symbol = "arrow-right", style = "button") =>
  `<a class="${style}" href="#/${route}">${label}${symbol ? icon(symbol) : ""}</a>`;
const ib = (label, action, symbol, extra = "") =>
  `<button class="icon-btn ${extra}" data-action="${action}" aria-label="${label}" title="${label}">${icon(symbol)}</button>`;
const avatar = (initials, tone = "", size = "") =>
  `<span class="avatar ${tone} ${size}">${esc(initials)}</span>`;
const subhead = (title, label = "", route = "") =>
  `<div class="subhead"><h2>${title}</h2>${label ? link(label, route, "arrow-up-right", "text-link") : ""}</div>`;
const field = (
  label,
  name,
  value = "",
  type = "text",
  required = false,
  attrs = "",
) =>
  `<label class="field"><span>${label}${required ? " *" : ""}</span><input name="${name}" type="${type}" value="${esc(value)}" ${required ? "required" : ""} ${attrs}></label>`;
const area = (label, name, value = "", required = false) =>
  `<label class="field"><span>${label}${required ? " *" : ""}</span><textarea name="${name}" ${required ? "required" : ""}>${esc(value)}</textarea></label>`;
const submit = (label) =>
  `<button type="submit" class="button">${label}${icon("arrow-right")}</button>`;
const companies = [
  {
    name: "Atelier Rivage",
    short: "AR",
    sector: "Architecture",
    line: "Des espaces qui vous ressemblent.",
    color: "#e8f0ec",
    ink: "#397459",
    member: 0,
    description:
      "Atelier Rivage accompagne les projets de rénovation et d’aménagement dans le Cotentin. Une approche attentive aux usages, aux matériaux et à la singularité de chaque lieu.",
  },
  {
    name: "Studio Horizon",
    short: "SH",
    sector: "Communication",
    line: "Les idées prennent forme.",
    color: "#eeebf7",
    ink: "#574687",
    member: 1,
    description:
      "Identité de marque, communication et création de contenus : Studio Horizon accompagne les entreprises dans leurs projets et donne une voix singulière à leurs idées.",
  },
  {
    name: "Cabinet Orion",
    short: "OR",
    sector: "Conseil",
    line: "Entreprendre, bien accompagné.",
    color: "#e7f3f8",
    ink: "#356679",
    member: 2,
    description:
      "Un accompagnement de proximité pour structurer vos projets, piloter votre activité et avancer avec confiance.",
  },
  {
    name: "Maison & Perspectives",
    short: "MP",
    sector: "Immobilier",
    line: "Votre prochain chapitre.",
    color: "#f6eeeb",
    ink: "#885e54",
    member: 3,
    description:
      "Conseil et accompagnement immobilier dans le Cotentin. Une relation de confiance, de la première rencontre à la concrétisation du projet.",
  },
  {
    name: "Cotentin Connect",
    short: "CC",
    sector: "Numérique",
    line: "Le numérique à votre rythme.",
    color: "#e5f5f5",
    ink: "#257c82",
    member: 4,
    description:
      "Conception de solutions numériques, sites web et outils métiers pour les entreprises du territoire.",
  },
  {
    name: "Ligne & Matière",
    short: "LM",
    sector: "Artisanat",
    line: "Le soin du détail.",
    color: "#f1f1ed",
    ink: "#657353",
    member: 5,
    description:
      "Un savoir-faire artisanal au service des espaces professionnels et des projets sur mesure.",
  },
];
const members = [
  {
    name: "Camille Martin",
    first: "Camille",
    last: "Martin",
    initials: "CM",
    company: 0,
    tone: "",
    role: "Architecte d’intérieur",
  },
  {
    name: "Alex Morel",
    first: "Alex",
    last: "Morel",
    initials: "AM",
    company: 1,
    tone: "alt",
    role: "Direction artistique",
  },
  {
    name: "Julien Perrin",
    first: "Julien",
    last: "Perrin",
    initials: "JP",
    company: 2,
    tone: "",
    role: "Conseil aux entreprises",
  },
  {
    name: "Louise Laurent",
    first: "Louise",
    last: "Laurent",
    initials: "LL",
    company: 3,
    tone: "rose",
    role: "Conseillère en immobilier",
  },
  {
    name: "Thomas Robin",
    first: "Thomas",
    last: "Robin",
    initials: "TR",
    company: 4,
    tone: "alt",
    role: "Développement numérique",
  },
  {
    name: "Émilie Dubois",
    first: "Émilie",
    last: "Dubois",
    initials: "ED",
    company: 5,
    tone: "",
    role: "Artisane",
  },
];
const news = [
  {
    title: "De belles rencontres. De nouvelles perspectives.",
    tag: "LA VIE DU CLUB",
    date: "2 octobre 2026",
    image: "assets/actu.jpg",
    intro:
      "Prendre le temps de se rencontrer, partager ses expériences et faire avancer ses projets. C’est tout l’esprit de nos rendez-vous.",
    body: "Lors de notre dernier échange, les entrepreneurs ont croisé leurs regards sur le développement de leur activité. Des conversations concrètes, de nouvelles idées et l’envie de continuer à construire ensemble.",
  },
  {
    title: "Ces liens qui font grandir nos entreprises",
    tag: "DANS LE RÉSEAU",
    date: "30 septembre 2026",
    image: "assets/workspace.jpg",
    intro:
      "Un conseil au bon moment, une mise en relation, un projet partagé : le réseau se construit dans les échanges du quotidien.",
    body: "Au CEC, chaque rencontre est une occasion de mieux connaître les savoir-faire du territoire. Découvrez les entreprises et les membres qui donnent vie au réseau.",
  },
  {
    title: "Bienvenue aux nouveaux visages du Club",
    tag: "LES MEMBRES",
    date: "25 septembre 2026",
    image: "assets/actu.jpg",
    intro:
      "De nouveaux parcours et de nouvelles expertises viennent enrichir nos échanges.",
    body: "Retrouvez les nouveaux membres dans l’annuaire et prenez le temps de découvrir leurs activités. Le prochain rendez-vous sera une belle occasion de faire connaissance.",
  },
];
const meetings = [
  {
    day: "14",
    month: "OCT",
    date: "Mercredi 14 octobre",
    time: "07:30",
    title: "Le rendez-vous des entrepreneurs",
    place: "Maison des entrepreneurs",
    address: "Cherbourg-en-Cotentin",
    past: false,
  },
  {
    day: "28",
    month: "OCT",
    date: "Mercredi 28 octobre",
    time: "07:30",
    title: "Rencontres & projets",
    place: "Espace du Club",
    address: "Cherbourg-en-Cotentin",
    past: false,
  },
  {
    day: "24",
    month: "SEP",
    date: "Jeudi 24 septembre",
    time: "07:30",
    title: "La rentrée du réseau",
    place: "Maison des entrepreneurs",
    address: "Cherbourg-en-Cotentin",
    past: true,
  },
];
const state = {
  member: true,
  listState: "ready",
  directoryTab: "companies",
  sector: "Tous",
  search: "",
  meetingTab: "upcoming",
  exchangeTab: "received",
  notifications: true,
  read: false,
  blocked: new Set(),
  hidden: new Set(),
  guests: {
    0: [{ first: "Morgan", last: "Petit", company: "Perspective Studio" }],
    1: [],
    2: [],
  },
  profile: {
    first: "Camille",
    last: "Martin",
    phone: "",
    presentation:
      "Architecte d’intérieur dans le Cotentin. J’imagine des lieux qui allient sens, confort et personnalité.",
  },
  media: {},
  filenames: {},
  recommendations: [
    {
      name: "Sarah Lefèvre",
      from: 1,
      description:
        "Un projet d’aménagement de nouveaux bureaux à Cherbourg. Sarah recherche un accompagnement de la conception à la réalisation.",
      date: "Aujourd’hui",
      email: "sarah@example.test",
      phone: "",
      sent: false,
    },
    {
      name: "Nicolas Durand",
      from: 2,
      description:
        "Un projet de rénovation d’un espace professionnel. Un premier échange permettrait de préciser les besoins.",
      date: "30 septembre",
      email: "nicolas@example.test",
      phone: "",
      sent: false,
    },
    {
      name: "Léa Bernard",
      from: 3,
      description: "Mise en relation pour une identité de marque.",
      date: "28 septembre",
      email: "lea@example.test",
      phone: "",
      sent: true,
    },
  ],
  thanks: [
    {
      from: 3,
      amount: 2400,
      description:
        "Merci pour cette mise en relation de qualité. Un beau projet qui commence !",
      date: "1 octobre 2026",
      sent: false,
    },
    {
      from: 1,
      amount: 850,
      description:
        "Un premier projet réalisé grâce au réseau. Merci pour ta confiance.",
      date: "26 septembre 2026",
      sent: false,
    },
  ],
  success: null,
};
const screens = [
  ["home", "Le Club · actualités"],
  ["article/0", "Article"],
  ["agenda", "Réunions"],
  ["meeting/0", "Réunion · invités"],
  ["meeting/2", "Réunion · compte rendu"],
  ["invite/0", "Ajouter un invité"],
  ["directory", "Annuaire · entreprises / membres"],
  ["company/0", "Fiche entreprise"],
  ["member/1", "Fiche membre"],
  ["account", "Mon espace"],
  ["recommendations", "Recommandations"],
  ["recommendation/0", "Recommandation reçue"],
  ["new-recommendation", "Nouvelle recommandation"],
  ["thanks", "Remerciements"],
  ["thank/0", "Remerciement reçu"],
  ["new-thanks", "Nouveau remerciement"],
  ["notifications", "Notifications"],
  ["notification-settings", "Réglages des notifications"],
  ["profile", "Modifier mon profil"],
  ["company-edit", "Modifier mon entreprise"],
  ["password", "Mot de passe"],
  ["visibility", "Visibilité du profil"],
  ["blocked", "Membres bloqués"],
  ["login", "Connexion"],
  ["legal", "Confidentialité et assistance"],
  ["privacy", "Confidentialité"],
  ["terms", "Règles d’utilisation"],
  ["delete-account", "Suppression du compte"],
];
const protectedRoutes = new Set([
  "account",
  "recommendations",
  "recommendation",
  "new-recommendation",
  "thanks",
  "thank",
  "new-thanks",
  "profile",
  "company-edit",
  "password",
  "visibility",
  "blocked",
  "notifications",
  "notification-settings",
  "invite",
]);
let route = "home",
  itemId = 0,
  previousRoute = "home",
  returnAfterLogin = "account",
  toastTimer;
const activeGroup = () =>
  ["home", "article"].includes(route)
    ? "home"
    : ["agenda", "meeting", "invite"].includes(route)
      ? "agenda"
      : ["directory", "company", "member"].includes(route)
        ? "directory"
        : "account";
const go = (path) => {
  if (location.hash === "#/" + path) render();
  else location.hash = "#/" + path;
};
const money = (n) =>
  new Intl.NumberFormat("fr-FR", {
    style: "currency",
    currency: "EUR",
    maximumFractionDigits: 0,
  }).format(n);
const logo = (c, large = false) =>
  `<span class="company-logo" style="background:${large ? "white" : c.color};color:${c.ink}">${c === companies[0] && state.media.logo ? `<img src="${state.media.logo}" alt="Logo de ${esc(c.name)}">` : esc(c.short)}</span>`;
function header() {
  return `<header class="topbar"><a class="brand" href="#/home" aria-label="Accueil CEC"><img src="assets/logo_purple_nobg.png" alt="CEC"><span>Entrepreneurs<br>du Cotentin</span></a><div class="top-actions">${state.member ? ib("Notifications", "notifications", "bell", state.read ? "" : "notification-dot") : ib("Assistance", "legal", "circle-help")}</div></header>`;
}
function detail(title, fallback, extra = "") {
  return `<header class="detail-bar">${ib("Retour", "back:" + fallback, "arrow-left")}<h1>${title}</h1>${extra || '<span class="spacer"></span>'}</header>`;
}
function pageHead(title, subtitle = "", eyebrow = "") {
  return `<div class="page-head">${eyebrow ? `<span class="eyebrow">${eyebrow}</span>` : ""}<h1>${title}</h1>${subtitle ? `<p>${subtitle}</p>` : ""}</div>`;
}
function info(symbol, label, value) {
  return `<div class="info-row">${icon(symbol)}<div class="row-main"><p class="muted">${label}</p><p>${esc(value)}</p></div></div>`;
}
function menu(label, subtitle, symbol, path, count = "") {
  return `<a class="menu-row" href="#/${path}">${icon(symbol)}<span class="row-main"><strong>${label}</strong>${subtitle ? `<small>${subtitle}</small>` : ""}</span>${count ? `<span class="count">${count}</span>` : ""}${icon("chevron-right")}</a>`;
}
function memberRow(i) {
  const m = members[i],
    c = companies[m.company];
  return `<a class="company-row" href="#/member/${i}">${avatar(m.initials, m.tone)}<div class="row-main"><h3>${esc(m.name)}</h3><p>${esc(c.name)}</p><span class="small">${esc(m.role)}</span></div>${icon("chevron-right")}</a>`;
}
function meetingRow(i) {
  const m = meetings[i];
  return `<a class="meeting-row" href="#/meeting/${i}"><span class="date-tile"><b>${m.day}</b><span>${m.month}</span></span><div class="row-main">${!m.past && i === 0 ? '<span class="tiny-label">PROCHAIN RENDEZ-VOUS</span>' : ""}<h3>${m.title}</h3><p>${m.time.replace(":", "h")} · ${m.address}</p></div>${icon("chevron-right")}</a>`;
}
function empty(title, copy, symbol = "search", action = "") {
  return `<div class="empty-state">${icon(symbol)}<h2>${title}</h2><p>${copy}</p>${action}</div>`;
}
function listStatus(title, copy, action = "") {
  if (state.listState === "ready") return "";
  if (state.listState === "empty") return empty(title, copy, "inbox", action);
  if (state.listState === "loading")
    return `<div aria-label="Chargement en cours" role="status"><div class="skeleton"></div><div class="skeleton"></div><div class="skeleton"></div></div>`;
  return empty(
    "La connexion fait une pause",
    "Votre contenu sera de retour dès que la connexion sera rétablie.",
    "wifi-off",
    btn("Réessayer", "retry", "rotate-cw"),
  );
}
function segments(items, current, action) {
  return `<div class="segments" role="group" aria-label="Filtrer la liste">${items.map(([id, label]) => `<button data-action="${action}:${id}" class="${id === current ? "selected" : ""}" aria-pressed="${id === current}">${label}</button>`).join("")}</div>`;
}
function home() {
  return `${header()}<div class="page-head"><span class="eyebrow">VENDREDI 2 OCTOBRE</span><div class="welcome-line"><h1>${state.member ? `Bonjour, ${esc(state.profile.first)}.` : "La vie du Club."}</h1>${state.member ? `<a href="#/account" aria-label="Mon espace">${avatar("CM", "", "small")}</a>` : ""}</div><p>${state.member ? "Les nouvelles de votre réseau." : "Les entrepreneurs du Cotentin, ensemble."}</p></div>${
    listStatus(
      "Le Club prépare la suite",
      "Les prochaines actualités apparaîtront ici.",
    ) ||
    `<a class="feature" href="#/article/0"><img src="assets/actu.jpg" alt="Des professionnels réunis autour d’une table"><div class="feature-content"><span class="feature-tag">LA VIE DU CLUB</span><h2>Les rencontres<br>qui nous font<br>avancer.</h2><div class="feature-meta"><span>2 octobre · 3 min de lecture</span>${icon("arrow-up-right")}</div></div></a><div class="section-band">${subhead("À vos agendas", "Tout voir", "agenda")}${meetingRow(0)}</div>${subhead("Dans le réseau", "Annuaire", "directory")}<div class="pad">${news
      .slice(1)
      .map(
        (n, i) =>
          `<a class="news-row" href="#/article/${i + 1}"><img class="news-thumb" src="${n.image}" alt=""><div><span class="tiny-label">${n.tag}</span><h3>${n.title}</h3><p>${n.date}</p></div></a>`,
      )
      .join("")}</div>`
  }<div class="legal-footer"><a href="#/legal">À propos du CEC</a><span>·</span><a href="#/privacy">Confidentialité</a></div>`;
}
function article() {
  const n = news[itemId] || news[0];
  return `${detail("Le journal du Club", "home", ib("Partager", "share", "share-2"))}<img class="detail-media" src="${n.image}" alt="Rencontre et espace de travail"><article><div class="article-header"><span class="pill">${n.tag}</span><h1>${n.title}</h1><div class="inline">${avatar("CEC", "", "small")}<span class="byline">L’équipe CEC · ${n.date}</span></div></div><div class="pad body-copy"><p><strong>${n.intro}</strong></p><p>${n.body}</p><h2>Le réseau se vit au quotidien.</h2><p>Une recommandation, un remerciement ou simplement une conversation : chaque échange nourrit les liens entre les entrepreneurs du Cotentin.</p></div></article><div class="bottom-action">${link("Découvrir les entrepreneurs", "directory", "arrow-up-right", "button secondary")}</div><div class="pad">${menu("Signaler cet article", "", "flag", "report/article/" + itemId)}</div>`;
}
function agenda() {
  const ids = meetings
    .map((m, i) => i)
    .filter((i) => meetings[i].past === (state.meetingTab === "past"));
  return `${header()}${pageHead("On se retrouve ?", "Les rendez-vous qui font vivre le réseau.")}<div class="pad">${segments(
    [
      ["upcoming", "À venir"],
      ["past", "Passées"],
    ],
    state.meetingTab,
    "meeting-tab",
  )}</div>${listStatus("Rien de prévu pour le moment", "Les nouveaux rendez-vous apparaîtront ici.", "") || `<div class="pad"><p class="month-label">${state.meetingTab === "past" ? "SEPTEMBRE" : "OCTOBRE"} 2026</p>${ids.map(meetingRow).join("")}</div>`}<div class="pad"><div class="notice">${icon("bell")}<span>Une réunion planifiée ou modifiée ? Vous êtes informé par notification.</span></div></div>`;
}
function meeting() {
  const m = meetings[itemId] || meetings[0];
  return `${detail("Réunion du Club", "agenda", ib("Ajouter au calendrier", "calendar", "calendar-plus"))}<div class="meeting-hero"><span class="pill">${m.past ? "RENCONTRE PASSÉE" : "RENCONTRE CEC"}</span><h1>${m.title}</h1><p>${m.date} 2026</p></div><div class="pad">${info("clock-3", "Horaire", m.time.replace(":", "h"))}${info("map-pin", m.place, m.address)}<p class="subtle-label">${m.past ? "COMPTE RENDU" : "ORDRE DU JOUR"}</p>${m.past ? '<div class="body-copy"><p>Tour de table des projets de rentrée, présentation des nouvelles entreprises et partage des prochaines mises en relation.</p><p>Prochaine étape : poursuivre les échanges lors du rendez-vous d’octobre.</p></div>' : `<div class="agenda-step"><time>07:30</time><p>Accueil & café<small>Le temps de se retrouver.</small></p></div><div class="agenda-step"><time>07:45</time><p>Le tour des entrepreneurs<small>Vos actualités et vos projets.</small></p></div><div class="agenda-step"><time>08:30</time><p>Connexions & recommandations<small>Des échanges pour aller plus loin.</small></p></div>`}<div class="divider"></div><div class="inline spread"><h3>Les invités</h3><span class="pill neutral">${(state.guests[itemId] || []).length}</span></div>${(state.guests[itemId] || []).map((g) => `<div class="info-row">${avatar(g.first[0] + g.last[0], "alt", "small")}<div><p>${esc(g.first + " " + g.last)}</p><p class="muted">${esc(g.company)}</p></div></div>`).join("")}${!m.past ? `<div style="margin-top:22px">${link("Ajouter un invité", `invite/${itemId}`, "user-plus")}</div>` : ""}</div>`;
}
function invite() {
  return `${detail("Ajouter un invité", "meeting/" + itemId)}${pageHead("Une nouvelle rencontre.", "Invitez un entrepreneur à découvrir le Club.")}<form class="pad" data-form="invite"><div class="field-row">${field("Prénom", "first", "", "text", true)}${field("Nom", "last", "", "text", true)}</div>${field("Entreprise", "company")}<div class="notice">${icon("calendar-days")}<span>${(meetings[itemId] || meetings[0]).date} · 07h30</span></div>${submit("Ajouter l’invité")}</form>`;
}
function directory() {
  return `${header()}${pageHead("Le bon contact.", "Des talents d’ici. Des projets en commun.")}<div class="pad">${segments(
    [
      ["companies", "Entreprises"],
      ["members", "Membres"],
    ],
    state.directoryTab,
    "directory-tab",
  )}<label class="searchbox">${icon("search")}<input id="directory-search" type="search" aria-label="Rechercher dans l’annuaire" placeholder="Une entreprise, un nom, un métier…" value="${esc(state.search)}">${ib("Effacer la recherche", "clear-search", "x")}</label></div><div class="chips" role="group" aria-label="Secteur d’activité">${["Tous", "Architecture", "Communication", "Conseil", "Immobilier", "Numérique", "Artisanat"].map((s) => `<button data-action="sector:${s}" class="${state.sector === s ? "selected" : ""}" aria-pressed="${state.sector === s}">${s}</button>`).join("")}</div><div id="directory-results">${directoryResults()}</div>`;
}
function directoryResults() {
  const norm = (s) =>
    s
      .normalize("NFD")
      .replace(/[\u0300-\u036f]/g, "")
      .toLowerCase();
  const ids = companies
    .map((c, i) => i)
    .filter(
      (i) =>
        !state.hidden.has("company/" + i) &&
        !(
          state.directoryTab === "members" && state.hidden.has("member/" + i)
        ) &&
        !state.blocked.has(i) &&
        (state.sector === "Tous" || companies[i].sector === state.sector) &&
        norm(
          companies[i].name + " " + companies[i].sector + " " + members[i].name,
        ).includes(norm(state.search)),
    );
  return (
    listStatus(
      "Le réseau se prépare",
      "Les entreprises et les membres seront bientôt visibles ici.",
    ) ||
    `<div class="results-label"><span>${ids.length} ${state.directoryTab === "companies" ? "entreprise" : "membre"}${ids.length > 1 ? "s" : ""}</span><span>Cotentin</span></div><div class="company-list">${ids.length ? ids.map((i) => (state.directoryTab === "members" ? memberRow(i) : `<a class="company-row" href="#/company/${i}">${logo(companies[i])}<div class="row-main"><h3>${esc(companies[i].name)}</h3><p>${esc(companies[i].sector)}</p><span class="small">${esc(members[i].name)}</span></div>${icon("chevron-right")}</a>`)).join("") : empty("Aucun résultat", "Essayez un autre nom ou élargissez votre recherche.", "search", btn("Effacer les filtres", "reset-search", "rotate-ccw", "outline"))}</div>`
  );
}
function company() {
  const c = companies[itemId] || companies[0];
  return `${detail("L’entreprise", "directory", ib("Plus d’options", "more-company", "ellipsis"))}<div class="company-banner"><img src="${itemId === 0 && state.media.banner ? state.media.banner : "assets/workspace.jpg"}" alt="Espace de travail illustratif"></div><div class="company-identity">${logo(c, true)}<h1>${esc(c.name)}</h1><p>${esc(c.line)}</p><span class="pill">${esc(c.sector)}</span></div><div class="pad"><div class="divider"></div><h3>À propos</h3><p class="body-copy" style="margin-top:12px">${esc(c.description)}</p></div>${subhead("Les visages de l’entreprise")}<div class="pad">${memberRow(c.member)}${menu("Signaler une information", "", "flag", "report/company/" + itemId)}</div>`;
}
function member() {
  const m = members[itemId] || members[1],
    c = companies[m.company];
  return `${detail("Le membre", "directory", ib("Plus d’options", "more-member", "ellipsis"))}<div class="member-intro">${avatar(m.initials, m.tone, "large")}<h1>${esc(m.name)}</h1><p>${esc(m.role)} · ${esc(c.name)}</p><div class="action-pair">${btn("Écrire", "contact-email", "mail")}${btn("Appeler", "contact-phone", "phone", "outline")}</div></div><div class="pad"><h3>Une expertise, une rencontre.</h3><p class="body-copy" style="margin-top:12px">${itemId === 0 ? esc(state.profile.presentation) : "Entrepreneur dans le Cotentin, je crois à la force des échanges et des projets construits ensemble. Au plaisir de faire votre connaissance."}</p><p class="subtle-label">ENTREPRISE</p><a class="company-row" href="#/company/${m.company}">${logo(c)}<div class="row-main"><h3>${esc(c.name)}</h3><p>${esc(c.sector)}</p></div>${icon("arrow-up-right")}</a>${info("mail", "Email", m.first.toLowerCase() + "@example.test")}<div style="margin-top:22px">${link("Faire une recommandation", "new-recommendation?to=" + itemId, "send", "button secondary")}</div>${menu("Signaler ce membre", "", "flag", "report/member/" + itemId)}</div>`;
}
function account() {
  return `${header()}<div class="account-header">${state.media.photo ? `<span class="avatar large"><img src="${state.media.photo}" alt="Votre photo"></span>` : avatar("CM", "", "large")}<div><span class="tiny-label">MON ESPACE</span><h1>${esc(state.profile.first)} ${esc(state.profile.last)}</h1><p>${esc(companies[0].name)}</p></div></div><div class="account-stats"><button data-action="recommendations"><b>${state.recommendations.filter((r) => !r.sent).length}</b><span>Recommandations reçues</span></button><button data-action="thanks"><b>${state.thanks.filter((t) => !t.sent).length}</b><span>Remerciements reçus</span></button></div><div class="pad"><p class="subtle-label">FAIRE VIVRE LE RÉSEAU</p>${menu("Mes recommandations", "Mettre les bonnes personnes en relation", "send", "recommendations")}${menu("Mes remerciements", "Valoriser les liens qui portent leurs fruits", "handshake", "thanks")}<p class="subtle-label">MA PRÉSENCE</p>${menu("Mon profil", "Coordonnées, présentation et photo", "user-round", "profile")}${menu("Mon entreprise", "Identité, logo et bannière", "building-2", "company-edit")}${menu("Visibilité de mon profil", "Les informations visibles dans l’annuaire", "eye", "visibility")}<p class="subtle-label">PRÉFÉRENCES & SÉCURITÉ</p>${menu("Notifications", state.notifications ? "Activées sur cet appareil" : "Désactivées", "bell", "notification-settings")}${menu("Mot de passe", "Sécuriser mon compte", "lock-keyhole", "password")}${menu("Membres bloqués", `${state.blocked.size} membre bloqué`, "shield", "blocked")}${menu("Confidentialité et assistance", "", "circle-help", "legal")}<button class="menu-row danger-text" data-action="logout">${icon("log-out")}<strong>Se déconnecter</strong></button></div>`;
}
function exchangeCard(r, i, thanks = false) {
  const m = members[r.from] || members[1];
  return `<a class="entry-card" href="#/${thanks ? "thank" : "recommendation"}/${i}"><div class="inline">${avatar(m.initials, m.tone, "small")}<div class="row-main"><span class="tiny-label">${r.sent ? "ENVOYÉ À" : "REÇU DE"}</span><span class="small">${esc(m.name)}</span></div>${!r.sent ? '<span class="pill">Reçu</span>' : ""}</div>${thanks ? `<h3>Un lien qui porte ses fruits.</h3><div class="amount">${money(r.amount)}</div>` : `<h3>${esc(r.name)}</h3>`}<p>${esc(r.description.slice(0, 110))}${r.description.length > 110 ? "…" : ""}</p><footer><span>${esc(r.date)}</span><span class="inline">Voir le détail ${icon("arrow-up-right")}</span></footer></a>`;
}
function exchanges(thanks = false) {
  const data = thanks ? state.thanks : state.recommendations;
  const ids = data
    .map((r, i) => i)
    .filter(
      (i) =>
        data[i].sent === (state.exchangeTab === "sent") &&
        !state.hidden.has((thanks ? "thank" : "recommendation") + "/" + i),
    );
  return `${detail(thanks ? "Remerciements" : "Recommandations", "account")}${pageHead(thanks ? "Chaque lien compte." : "Les bonnes connexions.", thanks ? "Les échanges qui deviennent des projets." : "Votre réseau vous ouvre des portes.")}<div class="pad">${segments(
    [
      ["received", thanks ? "Reçus" : "Reçues"],
      ["sent", thanks ? "Envoyés" : "Envoyées"],
    ],
    state.exchangeTab,
    "exchange-tab",
  )}</div>${listStatus(thanks ? "Pas encore de remerciement" : "Pas encore de recommandation", "Vos prochains échanges apparaîtront ici.") || `<div class="pad">${ids.length ? ids.map((i) => exchangeCard(data[i], i, thanks)).join("") : empty("Une nouvelle histoire à écrire", "Commencez par un échange avec un membre du réseau.", thanks ? "handshake" : "send")}</div>`}<div class="list-action">${link(thanks ? "Remercier un membre" : "Faire une recommandation", thanks ? "new-thanks" : "new-recommendation", "plus")}</div>`;
}
function exchangeDetail(thanks = false) {
  const r = (thanks ? state.thanks : state.recommendations)[itemId];
  if (!r)
    return empty(
      "Contenu indisponible",
      "Ce contenu n’est plus disponible.",
      "inbox",
      link("Retour", "account"),
    );
  const m = members[r.from];
  return `${detail(thanks ? "Remerciement" : "Recommandation", thanks ? "thanks" : "recommendations", ib("Signaler", "report-current", "flag"))}<div class="page-head"><span class="eyebrow">${r.sent ? "ENVOYÉ À" : "REÇU DE"} ${esc(m.name.toUpperCase())}</span><h1>${thanks ? "Merci pour ce lien." : esc(r.name)}</h1><p>${esc(r.date)}</p></div><div class="pad">${thanks ? `<div class="meeting-hero" style="padding:22px;border-radius:8px"><span class="tiny-label">MONTANT DU PROJET</span><h2 style="font-size:32px">${money(r.amount)}</h2></div>` : `${info("mail", "Email du contact", r.email || "Non renseigné")}${info("phone", "Téléphone du contact", r.phone || "Non renseigné")}`}<p class="subtle-label">${thanks ? "LE MESSAGE" : "LE PROJET"}</p><p class="body-copy" style="margin:12px 0 24px">${esc(r.description)}</p>${memberRow(r.from)}${!thanks ? `<div class="action-pair">${btn("Écrire", "contact-email", "mail")}${btn("Appeler", "contact-phone", "phone", "outline")}</div>${link("Remercier " + esc(m.first), "new-thanks?to=" + r.from, "handshake", "button secondary")}` : ""}</div>`;
}
function recipient() {
  const selected =
    new URLSearchParams(location.hash.split("?")[1] || "").get("to") || "";
  return `<label class="field"><span>Membre destinataire *</span><select name="recipient" required><option value="">Choisir un membre</option>${members
    .slice(1)
    .map(
      (m, j) =>
        `<option value="${j + 1}" ${selected === String(j + 1) ? "selected" : ""}>${esc(m.name)} · ${esc(companies[m.company].name)}</option>`,
    )
    .join("")}</select></label>`;
}
function createExchange(thanks = false) {
  return `${detail(thanks ? "Nouveau remerciement" : "Nouvelle recommandation", thanks ? "thanks" : "recommendations")}${pageHead(thanks ? "Dire merci, simplement." : "Une rencontre à partager.", thanks ? "Un projet réalisé grâce au réseau ?" : "Transmettez un contact au bon membre.")}<form class="pad" data-form="${thanks ? "thanks" : "recommendation"}">${recipient()}<div class="divider"></div>${thanks ? `${field("Montant du projet (€)", "amount", "", "number", true, 'min="0.01" step="0.01" inputmode="decimal"')}${field("Date", "date", "2026-10-02", "date", true)}` : `<div class="field-row">${field("Prénom du contact", "first", "", "text", true)}${field("Nom du contact", "last", "", "text", true)}</div>${field("Email du contact", "email", "", "email")}${field("Téléphone du contact", "phone", "", "tel")}`}${area(thanks ? "Votre message" : "Le projet en quelques mots", "description")}<div class="notice">${icon("bell")}<span>Le membre sera averti de votre ${thanks ? "remerciement" : "recommandation"}.</span></div>${submit(thanks ? "Envoyer le remerciement" : "Transmettre le contact")}</form>`;
}
function notifications() {
  return `${detail("Notifications", "home", ib("Tout marquer comme lu", "mark-read", "check-check"))}${pageHead("Le réseau en mouvement.", "Les nouvelles qui vous concernent.")}<div class="pad"><span class="eyebrow">AUJOURD’HUI</span></div>${
    listStatus(
      "Vous êtes à jour",
      "Vos recommandations, remerciements et réunions apparaîtront ici.",
      "",
    ) ||
    [
      [
        "send",
        "Une nouvelle recommandation",
        "Alex vous met en relation avec Sarah Lefèvre.",
        "Il y a 25 min",
        "recommendation/0",
      ],
      [
        "handshake",
        "Louise vous remercie",
        "Un projet concrétisé grâce à votre mise en relation.",
        "Il y a 1 h",
        "thank/0",
      ],
      [
        "calendar-days",
        "Un nouveau rendez-vous",
        "Le prochain rendez-vous du Club est fixé au 14 octobre.",
        "Il y a 2 h",
        "meeting/0",
      ],
      [
        "calendar-clock",
        "Réunion mise à jour",
        "Le lieu du rendez-vous du 28 octobre a été modifié.",
        "Hier · 16:42",
        "meeting/1",
      ],
    ]
      .map(
        ([symbol, title, copy, time, path]) =>
          `<a class="notification-row ${state.read ? "" : "unread"}" href="#/${path}"><span class="notification-icon">${icon(symbol)}</span><div><h3>${title}</h3><p>${copy}</p><time>${time}</time></div></a>`,
      )
      .join("")
  }<div class="pad">${menu("Gérer mes notifications", "", "settings-2", "notification-settings")}</div>`;
}
function notificationSettings() {
  return `${detail("Notifications", "account")}${pageHead("Les bonnes nouvelles.", "Restez informé sans avoir à y penser.")}<div class="pad"><label class="switch-row"><span><strong>Notifications sur cet appareil</strong><small>${state.notifications ? "Autorisation accordée · appareil enregistré" : "Les notifications sont désactivées"}</small></span><input class="switch" type="checkbox" id="notifications-toggle" ${state.notifications ? "checked" : ""} aria-label="Notifications sur cet appareil"></label><p class="subtle-label">VOUS ÊTES AVERTI POUR</p>${info("send", "Recommandations", "Un membre vous transmet un contact")}${info("handshake", "Remerciements", "Un membre vous remercie")}${info("calendar-days", "Réunions", "Une réunion est planifiée ou modifiée")}<div class="notice">${icon("smartphone")}<span>Les autorisations se gèrent aussi dans les réglages de votre téléphone.</span></div>${btn("Ouvrir les réglages du téléphone", "device-settings", "settings-2", "outline")}</div>`;
}
function upload(kind, label, banner = false) {
  const preview = state.media[kind];
  return `<div class="${banner ? "" : "upload"}">${banner ? `<img class="banner-preview" src="${preview || "assets/workspace.jpg"}" alt="Aperçu de la bannière">` : kind === "photo" ? `<span class="avatar large">${preview ? `<img src="${preview}" alt="Aperçu de la photo">` : "CM"}</span>` : logo(companies[0])}<div><span class="small"><strong>${label}</strong></span><div class="upload-buttons"><button type="button" data-action="upload:${kind}:gallery">${icon("images")}Galerie</button><button type="button" data-action="upload:${kind}:files">${icon("folder-open")}Fichiers</button>${preview ? ib("Retirer le média", "remove-media:" + kind, "x") : ""}</div><small>${esc(state.filenames[kind] || "JPG, PNG ou WebP · 5 Mo maximum")}</small></div><input hidden type="file" accept="image/jpeg,image/png,image/webp" id="file-${kind}" data-media="${kind}"></div>`;
}
function profile() {
  return `${detail("Mon profil", "account")}${pageHead("Vous, tout simplement.", "Votre premier point de rencontre.")}<form class="pad" data-form="profile">${upload("photo", "Photo de profil")}<div class="field-row">${field("Prénom", "first", state.profile.first, "text", true)}${field("Nom", "last", state.profile.last, "text", true)}</div>${field("Téléphone", "phone", state.profile.phone, "tel")}${area("Présentation", "presentation", state.profile.presentation)}${submit("Enregistrer les modifications")}</form>`;
}
function companyEdit() {
  const c = companies[0];
  return `${detail("Mon entreprise", "account")}${pageHead("Votre savoir-faire.", "Une présence à la hauteur de vos projets.")}<form class="pad" data-form="company">${upload("logo", "Logo de l’entreprise")}${field("Nom de l’entreprise", "name", c.name, "text", true)}${field("Accroche", "line", c.line)}${field("Activités", "sector", c.sector)}${area("Description", "description", c.description)}<p class="subtle-label" style="margin-bottom:12px">BANNIÈRE</p>${upload("banner", "Photo de couverture", true)}<div style="margin-top:24px">${submit("Enregistrer les modifications")}</div></form>`;
}
function passwordField(label, name) {
  return `<label class="field"><span>${label} *</span><div class="password-wrap"><input name="${name}" type="password" autocomplete="${name === "current" ? "current-password" : "new-password"}" required ${name === "current" ? "" : 'minlength="8"'}>${ib("Afficher le mot de passe", "show-password:" + name, "eye")}</div></label>`;
}
function password() {
  return `${detail("Mot de passe", "account")}${pageHead("Votre compte, protégé.", "Choisissez un mot de passe personnel.")}<form class="pad" data-form="password">${passwordField("Mot de passe actuel", "current")}${passwordField("Nouveau mot de passe", "new")}${passwordField("Confirmer le mot de passe", "confirm")}<p class="field-hint">Au moins 8 caractères pour votre nouveau mot de passe.</p><p class="inline-form-error" role="alert"></p>${submit("Modifier le mot de passe")}</form>`;
}
function visibility() {
  return `${detail("Visibilité du profil", "account")}${pageHead("Votre présence publique.", "Ce que les visiteurs peuvent consulter.")}<div class="pad">${info("user-round", "Identité", state.profile.first + " " + state.profile.last)}${info("building-2", "Entreprise", companies[0].name)}${info("mail", "Coordonnées", "Email, téléphone et présentation")}<div class="notice">${icon("shield-check")}<span>Les recommandations et les remerciements restent dans votre espace connecté.</span></div>${link("Modifier mes informations", "profile", "pencil", "button outline")}</div>`;
}
function blocked() {
  return `${detail("Membres bloqués", "account")}${pageHead("Vos échanges, sereinement.")}<div class="pad">${state.blocked.size ? [...state.blocked].map((i) => `<div class="info-row">${avatar(members[i].initials)}<div class="row-main"><p>${members[i].name}</p></div><button class="text-link" data-action="unblock:${i}">Débloquer</button></div>`).join("") : empty("Aucun membre bloqué", "Vous pouvez bloquer un membre depuis les options de sa fiche.", "shield-check")}</div>`;
}
function login() {
  return `${detail("Espace membre", "home")}<div class="pad login"><img class="login-brand" src="assets/logo_purple_nobg.png" alt="CEC"><h1>Heureux de<br>vous retrouver.</h1><p>Vos contacts, vos projets et la vie du réseau<br>vous attendent.</p><form data-form="login" style="margin-top:24px">${field("Adresse email", "email", "", "email", true, 'autocomplete="email" placeholder="vous@entreprise.fr"')}${passwordField("Mot de passe", "current")}<label class="check"><input name="terms" type="checkbox" required><span>J’accepte les <a href="#/terms">conditions et règles d’utilisation</a>.</span></label>${submit("Se connecter")}</form><div class="legal-footer"><button data-action="support">Besoin d’aide ?</button><a href="#/privacy">Confidentialité</a></div></div>`;
}
function legal() {
  return `${detail("À propos & assistance", "account")}<div class="pad"><img class="login-brand" src="assets/logo_purple_nobg.png" alt="CEC"><h2>Club des Entrepreneurs<br>du Cotentin</h2><p class="body-copy" style="margin-top:12px">Des entrepreneurs, des rencontres et des projets partagés sur notre territoire.</p>${menu("Politique de confidentialité", "Données collectées et conservation", "shield-check", "privacy")}${menu("Conditions et règles d’utilisation", "Un réseau respectueux de chacun", "file-text", "terms")}${menu("Suppression du compte et des données", "Faire une demande par email", "user-round-minus", "delete-account")}<button class="menu-row" data-action="support">${icon("mail")}<span class="row-main"><strong>Contacter l’assistance</strong><small>contact@wevox.eu</small></span>${icon("arrow-up-right")}</button><p class="field-hint" style="margin-top:24px">CEC · Club des Entrepreneurs du Cotentin</p></div>`;
}
function policy(terms = false) {
  return `${detail(terms ? "Règles d’utilisation" : "Confidentialité", "legal")}<div class="pad body-copy"><h2>${terms ? "Un réseau de confiance." : "Vos données, en toute clarté."}</h2><p>${terms ? "L’espace public est accessible sans compte. Les fonctionnalités d’échange nécessitent un compte membre." : "Les coordonnées professionnelles, les informations de profil et les médias permettent de présenter votre activité dans l’annuaire."}</p><h2>${terms ? "Respecter les personnes" : "Vos échanges"}</h2><p>${terms ? "Les contenus injurieux, trompeurs, discriminatoires ou portant atteinte à la vie privée ne sont pas acceptés. Partagez uniquement les informations que vous êtes autorisé à transmettre." : "Les recommandations, remerciements et invitations sont utilisés pour le fonctionnement du réseau. Les identifiants de notification permettent d’adresser les alertes à votre téléphone."}</p><h2>${terms ? "Signaler ou bloquer" : "Conservation"}</h2><p>${terms ? "Un contenu peut être signalé depuis sa fiche. Vous pouvez également bloquer un membre depuis ses options." : "Les données sont conservées pendant 2 ans. Vous pouvez demander la suppression de votre compte et de vos données par email."}</p><h2>Une question ?</h2><p>Notre adresse de contact : contact@wevox.eu.</p><div style="margin-top:24px">${link("Contacter l’assistance", "legal", "arrow-right", "button outline")}</div></div>`;
}
function deleteAccount() {
  return `${detail("Suppression du compte", "legal")}${pageHead("Vous gardez la main.")}<div class="pad body-copy"><p>Vous pouvez demander la suppression de votre compte et des données associées en écrivant à notre assistance.</p><h2>Comment faire ?</h2><p>Envoyez votre demande depuis l’adresse email de votre compte à <strong>contact@wevox.eu</strong>.</p><p>Indiquez « Suppression de mon compte CEC » dans l’objet. Nous pourrons vous demander de confirmer votre identité avant le traitement.</p><div class="notice">${icon("info")}<span>La durée de conservation annoncée est de 2 ans.</span></div>${btn("Préparer ma demande", "delete-request", "mail", "danger")}</div>`;
}
function success() {
  const s = state.success || {
    title: "C’est enregistré.",
    copy: "Vos modifications ont bien été prises en compte dans la maquette.",
    path: "account",
    label: "Retour à mon espace",
  };
  return `${detail("Confirmation", s.path)}<div class="success-screen"><span class="success-symbol">${icon("check")}</span><h1>${s.title}</h1><p>${s.copy}</p>${link(s.label, s.path, "arrow-right")}</div>`;
}
function reportScreen() {
  const target = location.hash.split("#/report/")[1] || "company/0";
  return `${detail("Signaler un contenu", target.split("/")[0] === "article" ? "home" : target)}${pageHead("Merci de votre vigilance.", "Votre signalement sera examiné par l’équipe.")}<form class="pad" data-form="report" data-target="${esc(target)}"><label class="field"><span>Motif *</span><select name="reason" required><option value="">Choisir un motif</option><option>Contenu inapproprié</option><option>Information fausse ou trompeuse</option><option>Atteinte à la vie privée</option><option>Droits d’auteur ou droit à l’image</option><option>Spam ou contenu commercial abusif</option><option>Autre motif</option></select></label>${area("Précisions", "details")}<label class="check"><input type="checkbox" name="hide"><span>Masquer aussi ce contenu pour moi</span></label>${submit("Envoyer le signalement")}</form>`;
}
const renderers = {
  home,
  article,
  agenda,
  meeting,
  invite,
  directory,
  company,
  member,
  account,
  recommendations: () => exchanges(),
  recommendation: () => exchangeDetail(),
  "new-recommendation": () => createExchange(),
  thanks: () => exchanges(true),
  thank: () => exchangeDetail(true),
  "new-thanks": () => createExchange(true),
  notifications,
  "notification-settings": notificationSettings,
  profile,
  "company-edit": companyEdit,
  password,
  visibility,
  blocked,
  login,
  legal,
  privacy: () => policy(),
  terms: () => policy(true),
  "delete-account": deleteAccount,
  success,
  report: reportScreen,
};
function refreshIcons() {
  lucide.createIcons({ attrs: { "stroke-width": 1.65 } });
}
function render(keepScroll = false) {
  const app = $("#app"),
    scroll = app.scrollTop;
  const path = location.hash.replace(/^#\/?/, "").split("?")[0] || "home";
  const parts = path.split("/");
  route = parts[0];
  itemId = Number(parts[1]) || 0;
  if (!state.member && protectedRoutes.has(route)) {
    returnAfterLogin = path;
    go("login");
    return;
  }
  app.innerHTML = `<div class="screen">${state.hidden.has(path) ? `${detail("Contenu masqué", "directory")}${empty("Ce contenu est masqué", "Vous avez choisi de masquer ce contenu dans cette session.", "eye-off", link("Retour à l’annuaire", "directory"))}` : (renderers[route] || home)()}</div>`;
  app.querySelectorAll('a[href^="#/"]').forEach((a) => {
    if (state.hidden.has(a.getAttribute("href").slice(2))) a.remove();
  });
  const nav = $("#navigation");
  nav.innerHTML = [
    ["home", "house", "Le Club"],
    ["agenda", "calendar-days", "Agenda"],
    ["directory", "users-round", "Annuaire"],
    [
      state.member ? "account" : "login",
      state.member ? "user-round" : "log-in",
      state.member ? "Mon espace" : "Connexion",
    ],
  ]
    .map(
      ([path, symbol, label]) =>
        `<button data-action="${path}" ${activeGroup() === (path === "login" ? "account" : path) ? 'class="active" aria-current="page"' : ""}>${icon(symbol)}<span>${label}</span></button>`,
    )
    .join("");
  nav.hidden = !["home", "agenda", "directory", "account"].includes(route);
  app.style.paddingBottom = nav.hidden ? "36px" : "";
  app.scrollTop = keepScroll ? scroll : 0;
  $("#screen-picker").value = screens.some(([p]) => p === path) ? path : "home";
  refreshIcons();
  app.focus({ preventScroll: true });
}
function toast(message) {
  const t = $("#toast");
  t.textContent = message;
  t.classList.add("show");
  clearTimeout(toastTimer);
  toastTimer = setTimeout(() => t.classList.remove("show"), 3800);
}
function sheet(title, content) {
  const d = $("#sheet");
  d.innerHTML = `<div class="sheet-handle"></div>${ib("Fermer", "close-sheet", "x", "close-sheet")}<h2 id="sheet-title">${title}</h2>${content}`;
  refreshIcons();
  d.showModal();
}
function closeSheet() {
  $("#sheet").close();
}
function confirmed(title, copy, path, label) {
  state.success = { title, copy, path, label };
  go("success");
}
function action(value, button) {
  const [name, arg, source] = value.split(":");
  switch (name) {
    case "back":
      go(arg || previousRoute || "home");
      break;
    case "retry":
      state.listState = "ready";
      $("#state-picker").value = "ready";
      render(true);
      break;
    case "directory-tab":
      state.directoryTab = arg;
      render(true);
      break;
    case "meeting-tab":
      state.meetingTab = arg;
      render(true);
      break;
    case "exchange-tab":
      state.exchangeTab = arg;
      render(true);
      break;
    case "sector":
      state.sector = arg;
      render(true);
      break;
    case "clear-search":
      state.search = "";
      $("#directory-search").value = "";
      $("#directory-results").innerHTML = directoryResults();
      refreshIcons();
      $("#directory-search").focus();
      break;
    case "reset-search":
      state.search = "";
      state.sector = "Tous";
      render();
      break;
    case "mark-read":
      state.read = true;
      render(true);
      toast("Toutes les notifications sont marquées comme lues.");
      break;
    case "close-sheet":
      closeSheet();
      break;
    case "share":
      sheet(
        "Partager cet article",
        `<p>${esc((news[itemId] || news[0]).title)}</p><div class="sheet-options"><button data-action="copy-link">${icon("link")}Copier le lien</button><button data-action="demo-share">${icon("mail")}Envoyer par email</button></div>`,
      );
      break;
    case "copy-link":
      if (navigator.clipboard)
        navigator.clipboard
          .writeText(location.href)
          .then(() => toast("Lien local de la maquette copié."))
          .catch(() => toast("Copiez le lien dans la barre d’adresse."));
      else toast("Copiez le lien dans la barre d’adresse.");
      closeSheet();
      break;
    case "demo-share":
      closeSheet();
      toast("Partage simulé. Aucun email n’a été envoyé.");
      break;
    case "calendar":
      sheet(
        "Ajouter à mon calendrier",
        `<p>${(meetings[itemId] || meetings[0]).date} · 07h30<br>${(meetings[itemId] || meetings[0]).title}</p>${btn("Ajouter le rendez-vous", "calendar-confirm", "calendar-plus")}`,
      );
      break;
    case "calendar-confirm":
      closeSheet();
      toast("Ajout au calendrier simulé dans la maquette.");
      break;
    case "more-company":
      sheet(
        "Options de l’entreprise",
        `<div class="sheet-options"><button data-action="report-current">${icon("flag")}Signaler une information</button></div>`,
      );
      break;
    case "more-member":
      sheet(
        "Gérer cette relation",
        `<div class="sheet-options"><button data-action="report-current">${icon("flag")}Signaler ce membre</button>${state.member ? `<button data-action="block:${itemId}">${icon("shield-ban")}${state.blocked.has(itemId) ? "Débloquer" : "Bloquer"} ce membre</button>` : ""}</div>`,
      );
      break;
    case "report-current":
      closeSheet();
      go(`report/${route}/${itemId}`);
      break;
    case "block":
      closeSheet();
      if (state.blocked.has(Number(arg))) {
        state.blocked.delete(Number(arg));
        toast("Membre débloqué.");
      } else
        sheet(
          "Bloquer ce membre ?",
          `<p>${esc(members[Number(arg)].name)} ne sera plus affiché dans votre annuaire. Vous pourrez revenir sur ce choix dans votre espace.</p>${btn("Bloquer le membre", "confirm-block:" + arg, "shield-ban", "danger")}${btn("Annuler", "close-sheet", "", "outline")}`,
        );
      break;
    case "confirm-block":
      state.blocked.add(Number(arg));
      closeSheet();
      go("directory");
      toast("Membre bloqué dans cette démo.");
      break;
    case "unblock":
      state.blocked.delete(Number(arg));
      render(true);
      toast("Membre débloqué.");
      break;
    case "contact-email":
      sheet(
        "Écrire un message",
        "<p>Dans l’application, cette action ouvre votre messagerie avec l’adresse du contact.</p><p>Les coordonnées de cette maquette sont fictives. Aucun message ne sera envoyé.</p>" +
          btn("Compris", "close-sheet", "", "outline"),
      );
      break;
    case "contact-phone":
      sheet(
        "Appeler le contact",
        "<p>Le téléphone n’est pas renseigné pour ce contact de démonstration. Dans l’application, un numéro renseigné ouvre le composeur du téléphone.</p>" +
          btn("Fermer", "close-sheet", "", "outline"),
      );
      break;
    case "device-settings":
      sheet(
        "Réglages du téléphone",
        "<p>La maquette ne modifie pas les réglages de votre appareil. Dans l’application, cette action ouvre les autorisations de notification.</p>" +
          btn("Fermer", "close-sheet", "", "outline"),
      );
      break;
    case "support":
      sheet(
        "L’assistance CEC",
        "<p>contact@wevox.eu</p><p>Cette maquette n’envoie pas d’email. Vous pouvez utiliser cette adresse pour contacter l’assistance.</p>" +
          btn("Fermer", "close-sheet", "", "outline"),
      );
      break;
    case "delete-request":
      sheet(
        "Votre demande de suppression",
        "<p>À : contact@wevox.eu<br>Objet : Suppression de mon compte CEC</p><p>Bonjour, je souhaite demander la suppression de mon compte CEC et des données associées à mon adresse email.</p><p>Aucune demande n’est envoyée depuis la maquette.</p>" +
          btn("Fermer", "close-sheet", "", "outline"),
      );
      break;
    case "logout":
      sheet(
        "Se déconnecter ?",
        `<p>Les actualités, les réunions et l’annuaire resteront accessibles sans connexion.</p>${btn("Se déconnecter", "confirm-logout", "log-out")}${btn("Rester connecté", "close-sheet", "", "outline")}`,
      );
      break;
    case "confirm-logout":
      closeSheet();
      state.member = false;
      $('[name="session"][value="public"]').checked = true;
      go("home");
      break;
    case "show-password": {
      const input = button.closest(".field").querySelector("input");
      input.type = input.type === "password" ? "text" : "password";
      button.setAttribute(
        "aria-label",
        input.type === "password"
          ? "Afficher le mot de passe"
          : "Masquer le mot de passe",
      );
      break;
    }
    case "upload": {
      const input = $("#file-" + arg);
      input.setAttribute(
        "accept",
        source === "gallery" ? "image/*" : ".jpg,.jpeg,.png,.webp",
      );
      input.click();
      break;
    }
    case "remove-media":
      if (state.media[arg]) URL.revokeObjectURL(state.media[arg]);
      delete state.media[arg];
      delete state.filenames[arg];
      preserveDraft();
      render(true);
      break;
    default:
      if (renderers[name]) go(name);
  }
}
function preserveDraft() {
  const f = $("#app form");
  if (!f) return;
  const d = Object.fromEntries(new FormData(f));
  if (f.dataset.form === "profile") Object.assign(state.profile, d);
  if (f.dataset.form === "company") Object.assign(companies[0], d);
}
document.addEventListener("click", (e) => {
  const b = e.target.closest("[data-action]");
  if (b) {
    e.preventDefault();
    action(b.dataset.action, b);
  }
});
document.addEventListener("input", (e) => {
  if (e.target.id === "directory-search") {
    state.search = e.target.value;
    $("#directory-results").innerHTML = directoryResults();
    refreshIcons();
  }
});
document.addEventListener("change", (e) => {
  const target = e.target;
  if (target.matches('[name="session"]')) {
    state.member = target.value === "member";
    render();
  }
  if (target.id === "state-picker") {
    state.listState = target.value;
    render(true);
  }
  if (target.id === "screen-picker") {
    go(target.value);
  }
  if (target.id === "notifications-toggle") {
    state.notifications = target.checked;
    render(true);
    toast("Préférence modifiée uniquement dans la maquette.");
  }
  if (target.dataset.media) {
    const file = target.files[0];
    if (!file) return;
    const kind = target.dataset.media;
    if (
      !["image/jpeg", "image/png", "image/webp"].includes(file.type) ||
      file.size > 5 * 1024 * 1024
    ) {
      toast("Choisissez un JPG, PNG ou WebP de moins de 5 Mo.");
      target.value = "";
      return;
    }
    preserveDraft();
    if (state.media[kind]) URL.revokeObjectURL(state.media[kind]);
    state.media[kind] = URL.createObjectURL(file);
    state.filenames[kind] = file.name;
    render(true);
  }
});
document.addEventListener("submit", (e) => {
  const f = e.target;
  if (!f.dataset.form) return;
  e.preventDefault();
  if (!f.reportValidity()) return;
  const d = Object.fromEntries(new FormData(f));
  switch (f.dataset.form) {
    case "login":
      state.member = true;
      $('[name="session"][value="member"]').checked = true;
      go(returnAfterLogin);
      toast("Session de démonstration ouverte.");
      break;
    case "recommendation":
      state.recommendations.unshift({
        name: d.first + " " + d.last,
        from: Number(d.recipient),
        description: d.description,
        email: d.email,
        phone: d.phone,
        date: "À l’instant",
        sent: true,
      });
      state.exchangeTab = "sent";
      confirmed(
        "Une connexion de plus.",
        "Votre recommandation est enregistrée dans la maquette. Aucun contact n’a été transmis.",
        "recommendations",
        "Voir mes recommandations",
      );
      break;
    case "thanks":
      state.thanks.unshift({
        from: Number(d.recipient),
        amount: Number(d.amount),
        description: d.description,
        date: new Date(d.date + "T12:00:00").toLocaleDateString("fr-FR"),
        sent: true,
      });
      state.exchangeTab = "sent";
      confirmed(
        "Un merci qui compte.",
        "Votre remerciement est enregistré dans la maquette. Aucune notification réelle n’a été envoyée.",
        "thanks",
        "Voir mes remerciements",
      );
      break;
    case "invite":
      (state.guests[itemId] ??= []).push(d);
      confirmed(
        "Une place pour une rencontre.",
        "L’invité a été ajouté à cette réunion de démonstration.",
        "meeting/" + itemId,
        "Revenir à la réunion",
      );
      break;
    case "profile":
      Object.assign(state.profile, d);
      members[0].name = d.first + " " + d.last;
      members[0].first = d.first;
      members[0].last = d.last;
      confirmed(
        "Votre profil est à jour.",
        "Les modifications sont visibles dans cette maquette uniquement.",
        "account",
        "Retour à mon espace",
      );
      break;
    case "company":
      Object.assign(companies[0], d);
      confirmed(
        "Votre entreprise, à jour.",
        "Les modifications sont visibles dans cette maquette uniquement.",
        "company/0",
        "Voir ma fiche entreprise",
      );
      break;
    case "password":
      if (d.new !== d.confirm) {
        $(".inline-form-error", f).textContent =
          "Les deux nouveaux mots de passe ne correspondent pas.";
        return;
      }
      f.reset();
      confirmed(
        "Votre sécurité, préservée.",
        "Simulation terminée. Aucun mot de passe n’a été enregistré ni envoyé.",
        "account",
        "Retour à mon espace",
      );
      break;
    case "report":
      if (d.hide) state.hidden.add(f.dataset.target);
      confirmed(
        "Merci pour votre vigilance.",
        "Votre signalement est simulé. Aucun signalement réel n’a été transmis.",
        "directory",
        "Retour à l’annuaire",
      );
      break;
  }
});
$("#sheet").addEventListener("click", (e) => {
  if (e.target === $("#sheet")) {
    const r = e.target.getBoundingClientRect();
    if (
      e.clientX < r.left ||
      e.clientX > r.right ||
      e.clientY < r.top ||
      e.clientY > r.bottom
    )
      closeSheet();
  }
});
$("#reset-demo").addEventListener("click", () => {
  location.hash = "#/home";
  location.reload();
});
$("#screen-picker").innerHTML = screens
  .map(([path, label]) => `<option value="${path}">${label}</option>`)
  .join("");
window.addEventListener("hashchange", () => {
  previousRoute = route;
  closeSheet();
  render();
});
if (new URLSearchParams(location.search).has("embed"))
  document.body.classList.add("embedded");
render();
