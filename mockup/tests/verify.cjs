const { chromium, expect } = require("@playwright/test");
const { pathToFileURL } = require("node:url");
const path = require("node:path");

const root = path.resolve(__dirname, "..");
const base = pathToFileURL(path.join(root, "index.html")).href;
const routes = [
  "home",
  "article/0",
  "agenda",
  "meeting/0",
  "meeting/2",
  "invite/0",
  "directory",
  "company/0",
  "member/1",
  "account",
  "recommendations",
  "recommendation/0",
  "new-recommendation",
  "thanks",
  "thank/0",
  "new-thanks",
  "notifications",
  "notification-settings",
  "profile",
  "company-edit",
  "password",
  "visibility",
  "blocked",
  "login",
  "legal",
  "privacy",
  "terms",
  "delete-account",
  "report/company/0",
];
const shots = [
  "home",
  "agenda",
  "meeting/0",
  "directory",
  "company/0",
  "member/1",
  "account",
  "recommendations",
  "new-recommendation",
  "thanks",
  "notifications",
  "profile",
  "login",
];
(async () => {
  const browser = await chromium.launch({ channel: "msedge", headless: true });
  const page = await browser.newPage({
    viewport: { width: 390, height: 844 },
    deviceScaleFactor: 1,
  });
  const errors = [];
  const external = [];
  page.on("pageerror", (e) => errors.push(e.message));
  page.on("request", (request) => {
    if (/^https?:/.test(request.url())) external.push(request.url());
  });
  await page.goto(base);
  await page.evaluate(() => document.fonts.ready);
  await expect(page.getByRole("heading", {name:"Bonjour, Camille."})).toBeVisible();
  await expect(page.locator('form[data-form="login"]')).toHaveCount(0);
  for (const width of [320, 390, 430]) {
    await page.setViewportSize({ width, height: 844 });
    for (const route of routes) {
      await page.goto(base + "#/" + route);
      await page.waitForTimeout(90);
      await expect(page.locator("#app .screen")).toBeVisible();
      await expect(page.getByText("Découvrir le Club sans compte", {exact:true})).toHaveCount(0);
      const overflow = await page.evaluate(() => {
        const app = document.querySelector("#app");
        const right = app.getBoundingClientRect().right;
        const out = [
          ...app.querySelectorAll(
            "h1,h2,h3,p,input,select,textarea,.button,.entry-card,.company-row",
          ),
        ].filter(
          (e) =>
            !e.closest(".chips") && e.getBoundingClientRect().right > right + 1,
        );
        return {
          body: document.documentElement.scrollWidth > innerWidth + 1,
          app: app.scrollWidth > app.clientWidth + 1,
          out: out.map((e) => e.tagName + ": " + e.textContent.slice(0, 45)),
        };
      });
      expect(overflow, `${width}px / ${route}`).toEqual({
        body: false,
        app: false,
        out: [],
      });
      expect(
        await page
          .locator("img")
          .evaluateAll((imgs) =>
            imgs
              .filter((i) => !i.complete || i.naturalWidth === 0)
              .map((i) => i.src),
          ),
        route + " images",
      ).toEqual([]);
      if (width === 390 && shots.includes(route)) {
        await page.waitForTimeout(260);
        await page.screenshot({
          path: path.join(
            root,
            "captures",
            route.replaceAll("/", "-") + ".png",
          ),
        });
      }
    }
  }

  await page.goto(base + "#/directory");
  await page.getByRole("searchbox").fill("Horizon");
  await expect(page.locator(".company-row")).toHaveCount(1);
  await page
    .getByRole("button", { name: "Effacer la recherche", exact: true })
    .click();
  await expect(page.locator(".company-row")).toHaveCount(6);
  await page.getByRole("button", { name: "Architecture", exact: true }).click();
  await expect(page.locator(".company-row")).toHaveCount(1);
  await page.getByRole("button", { name: "Tous", exact: true }).click();
  await page.getByRole("button", { name: "Membres", exact: true }).click();
  await expect(page.locator(".company-row").first()).toContainText("Camille");
  await page.goto(base + "#/company/0");
  const layering = await page.evaluate(() => {
    const logo = document.querySelector(".company-identity .company-logo");
    const r = logo.getBoundingClientRect();
    return logo.contains(document.elementFromPoint(r.x + r.width / 2, r.y + 8));
  });
  expect(layering, "Company logo is above its banner").toBe(true);

  await page.goto(base + "#/new-recommendation");
  await page.getByLabel("Membre destinataire").selectOption("1");
  await page.getByLabel("Prénom du contact").fill("Test");
  await page
    .getByRole("textbox", { name: "Nom du contact *", exact: true })
    .fill("Parcours");
  await page.getByLabel("Email du contact").fill("test@example.test");
  await page
    .getByLabel("Le projet en quelques mots")
    .fill("Un projet de démonstration.");
  await page.getByRole("button", { name: "Transmettre le contact" }).click();
  await expect(
    page.getByRole("heading", { name: "Une connexion de plus." }),
  ).toBeVisible();
  await page.getByRole("link", { name: "Voir mes recommandations" }).click();
  await expect(page.locator(".entry-card").first()).toContainText(
    "Test Parcours",
  );

  await page.goto(base + "#/new-thanks");
  await page.getByLabel("Membre destinataire").selectOption("2");
  await page.getByLabel("Montant du projet").fill("1250");
  await page.getByLabel("Votre message").fill("Merci pour le contact.");
  await page.getByRole("button", { name: "Envoyer le remerciement" }).click();
  await expect(
    page.getByRole("heading", { name: "Un merci qui compte." }),
  ).toBeVisible();

  await page.goto(base + "#/invite/0");
  await page.getByLabel("Prénom").fill("Charlie");
  await page.getByLabel("Nom", { exact: false }).last().fill("Demo");
  await page.getByLabel("Entreprise", { exact: true }).fill("Studio Test");
  await page
    .getByRole("button", { name: "Ajouter l’invité", exact: true })
    .click();
  await page.getByRole("link", { name: "Revenir à la réunion" }).click();
  await expect(page.locator("#app")).toContainText("Charlie Demo");

  await page.goto(base + "#/profile");
  await page.getByLabel("Prénom").fill("Cam");
  await page
    .locator("#file-photo")
    .setInputFiles(path.join(root, "assets", "actu.jpg"));
  await expect(page.getByLabel("Prénom")).toHaveValue("Cam");
  await expect(page.getByAltText("Aperçu de la photo")).toBeVisible();
  await page
    .getByRole("button", { name: "Enregistrer les modifications" })
    .click();
  await page.getByRole("link", { name: "Retour à mon espace" }).click();
  await expect(page.locator(".account-header")).toContainText("Cam Martin");

  await page.goto(base + "#/password");
  await page.locator("input[name=current]").fill("previous-test");
  await page.locator("input[name=new]").fill("new-test-password");
  await page.locator("input[name=confirm]").fill("different-password");
  await page.getByRole("button", { name: "Modifier le mot de passe" }).click();
  await expect(page.getByRole("alert")).toContainText("ne correspondent pas");

  await page.goto(base + "#/member/1");
  await page.getByRole("button", { name: "Plus d’options" }).click();
  await page.getByRole("button", { name: "Bloquer ce membre" }).click();
  await page.getByRole("button", { name: "Bloquer le membre" }).click();
  await page.goto(base + "#/blocked");
  await expect(page.locator("#app")).toContainText("Alex Morel");
  await page.getByRole("button", { name: "Débloquer", exact: true }).click();
  await expect(
    page.getByRole("heading", { name: "Aucun membre bloqué" }),
  ).toBeVisible();

  await page.goto(base + "#/notifications");
  await page.getByRole("button", { name: "Tout marquer comme lu" }).click();
  await expect(page.locator(".unread")).toHaveCount(0);
  await page.goto(base + "#/notification-settings");
  await page.getByRole("checkbox").uncheck();
  await expect(page.locator("#app")).toContainText(
    "Les notifications sont désactivées",
  );

  await page.goto(base + "#/company-edit");
  await page.getByLabel("Nom de l’entreprise").fill("Atelier Test");
  await page.locator("#file-logo").setInputFiles(path.join(root, "assets", "logo_purple_nobg.png"));
  await expect(page.getByLabel("Nom de l’entreprise")).toHaveValue("Atelier Test");
  await page.getByRole("button", {name:"Enregistrer les modifications"}).click();
  await page.getByRole("link", {name:"Voir ma fiche entreprise"}).click();
  await expect(page.getByRole("heading", {name:"Atelier Test", exact:true})).toBeVisible();
  await expect(page.locator(".company-identity .company-logo img")).toBeVisible();

  await page.goto(base + "#/report/company/1");
  await page.getByLabel("Motif").selectOption({label:"Information fausse ou trompeuse"});
  await page.getByRole("checkbox").check();
  await page.getByRole("button", {name:"Envoyer le signalement"}).click();
  await page.getByRole("link", {name:"Retour à l’annuaire"}).click();
  await expect(page.locator(".company-row")).toHaveCount(5);
  await page.goto(base + "#/company/1");
  await expect(page.getByRole("heading", {name:"Ce contenu est masqué"})).toBeVisible();

  await page.setViewportSize({ width: 1440, height: 1000 });
  await page.goto(base + "#/home");
  await page.reload();
  await page.evaluate(() => document.fonts.ready);
  await page.waitForTimeout(300);
  await page.screenshot({
    path: path.join(root, "captures", "studio-desktop.png"),
  });
  for (const mode of ["empty", "loading", "error"]) {
    await page.locator("#state-picker").selectOption(mode);
    await page.goto(base + "#/directory");
    await expect(
      page.locator(mode === "loading" ? ".skeleton" : ".empty-state").first(),
    ).toBeVisible();
  }
  await page.getByRole("button", { name: "Réessayer" }).click();
  await expect(page.locator(".company-row")).toHaveCount(6);
  await page.goto(base);
  await page.getByRole("radio", { name: "Visiteur", exact: true }).check();
  await expect(page.getByRole("heading", {name:"La vie du Club."})).toBeVisible();
  await expect(page.locator('form[data-form="login"]')).toHaveCount(0);
  for (const path of ['agenda', 'directory', 'article/0', 'company/0', 'member/1']) {
    await page.goto(base + '#/' + path);
    await expect(page.locator('form[data-form="login"]')).toHaveCount(0);
  }
  await page.goto(base + '#/home');
  await page.getByRole('button', {name:'Connexion', exact:true}).click();
  await expect(page.locator('form[data-form="login"]')).toBeVisible();
  await expect(page.getByText("Découvrir le Club sans compte", {exact:true})).toHaveCount(0);
  await page.getByRole('button', {name:'Retour', exact:true}).click();
  await expect(page.getByRole('heading', {name:'La vie du Club.'})).toBeVisible();
  await page.goto(base + "#/recommendations");
  await expect(
    page.getByRole("heading", { name: "Heureux de vous retrouver." }),
  ).toBeVisible();
  await page.getByLabel("Adresse email").fill("demo@example.test");
  await page.locator("input[name=current]").fill("demo-only");
  await page.locator("[name=terms]").check();
  await page.getByRole("button", { name: "Se connecter", exact: true }).click();
  await expect(
    page.getByRole("heading", { name: "Les bonnes connexions." }),
  ).toBeVisible();

  await page.goto(pathToFileURL(path.join(root, "board.html")).href);
  await page.setViewportSize({ width: 1440, height: 1200 });
  await expect(page.locator('.board-preview img')).toHaveCount(9);
  await page.evaluate(() => document.fonts.ready);
  expect(await page.locator('.board-preview img').evaluateAll(imgs => imgs.every(img => img.complete && img.naturalWidth > 0))).toBe(true);
  await page.waitForTimeout(400);
  await page.screenshot({
    path: path.join(root, "captures", "vue-ensemble.png"),
    fullPage: true,
  });
  expect(errors, "JavaScript errors").toEqual([]);
  expect(external, "No external requests").toEqual([]);
  console.log(
    JSON.stringify(
      {
        routes: routes.length,
        widths: [320, 390, 430],
        desktop: 1440,
        flows:
          "search, filters, logo layers, recommendation, thanks, invite, media, profile, company, password, block, report, notifications, states, login",
        screenshots: shots.length + 2,
        errors,
        externalRequests: external.length,
      },
      null,
      2,
    ),
  );
  await browser.close();
})().catch((error) => {
  console.error(error);
  process.exit(1);
});
