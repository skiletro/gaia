import fs from "node:fs/promises";

const lock = JSON.parse(await fs.readFile("package-lock.json", "utf8"));
await Promise.all(
  Object.entries(lock.packages).map(async ([path, pkg]) => {
    if (!path || pkg.inBundle || pkg.resolved) return;

    const name = path.split("node_modules/").at(-1);
    const response = await fetch(`https://registry.npmjs.org/${name}/${pkg.version}`);
    if (!response.ok) throw new Error(`Fetching ${name}@${pkg.version}: ${response.status}`);
    const { dist } = await response.json();
    pkg.resolved = dist.tarball;
    pkg.integrity = dist.integrity;
  }),
);
await fs.writeFile("package-lock.json", JSON.stringify(lock, null, 2) + "\n");
