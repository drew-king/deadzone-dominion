import { mkdir, writeFile } from "node:fs/promises";

const destination = new URL("./meshes/", import.meta.url);
await mkdir(destination, { recursive: true });

function model(name) {
  const vertices = [];
  const faces = [];
  function loft(rings, sides = 8, phase = Math.PI / 8) {
    const start = vertices.length;
    for (const [y, radiusX, radiusZ, centerX = 0, centerZ = 0] of rings) {
      for (let i = 0; i < sides; i++) {
        const a = phase - i * Math.PI * 2 / sides;
        vertices.push([centerX + Math.cos(a) * radiusX, y, centerZ + Math.sin(a) * radiusZ]);
      }
    }
    const triangle = (a, b, c) => faces.push([start + a + 1, start + b + 1, start + c + 1]);
    for (let r = 0; r < rings.length - 1; r++) {
      for (let i = 0; i < sides; i++) {
        const j = (i + 1) % sides;
        const bottom = r * sides;
        const top = bottom + sides;
        triangle(bottom + i, bottom + j, top + j);
        triangle(bottom + i, top + j, top + i);
      }
    }
    const top = (rings.length - 1) * sides;
    for (let i = 1; i < sides - 1; i++) {
      triangle(0, i + 1, i);
      triangle(top, top + i, top + i + 1);
    }
  }
  async function save() {
    const edges = new Map();
    for (const f of faces) {
      for (let i = 0; i < 3; i++) {
        const a = f[i], b = f[(i + 1) % 3];
        const key = a < b ? `${a}:${b}` : `${b}:${a}`;
        const [count, winding] = edges.get(key) ?? [0, 0];
        edges.set(key, [count + 1, winding + (a < b ? 1 : -1)]);
      }
    }
    if ([...edges.values()].some(([count, winding]) => count !== 2 || winding !== 0)) {
      throw new Error(`Open edge or inconsistent winding in ${name}`);
    }
    const contents = [
      "# Original Deadzone Dominion model, Y up, dimensions in studs",
      `o ${name}`,
      ...vertices.map((v) => `v ${v.map((x) => x.toFixed(5)).join(" ")}`),
      ...faces.map((f) => `f ${f.join(" ")}`),
      "",
    ].join("\n");
    await writeFile(new URL(`${name}.obj`, destination), contents);
    console.log(`${name}: ${vertices.length} vertices, ${faces.length} triangles`);
  }
  return { loft, save };
}

const reactor = model("ReactorBeacon");
reactor.loft([[0, 2.7, 2.7], [.7, 2.7, 2.7], [1.4, 1.7, 1.7],
  [4, 1.5, 1.5], [4.7, 2, 2], [5.2, 2, 2], [5.65, 1.17, 1.17]], 8);
await reactor.save();

for (let tier = 1; tier <= 4; tier++) {
  const cargo = model(`CargoTier${tier}`);
  if (tier === 1) cargo.loft([[-.58, .45, .5], [-.29, .68, .76], [.32, .68, .76], [.58, .45, .5]]);
  if (tier === 2) cargo.loft([[-.58, .62, .7], [-.38, .73, .8], [.39, .73, .8], [.58, .62, .7]], 12);
  if (tier === 3) cargo.loft([[-.65, .14, .22], [-.32, .8, .77], [.28, .8, .77], [.65, .16, .18]], 6);
  if (tier === 4) cargo.loft([[-.72, .45, .45], [-.3, .86, .86], [.32, .77, .78], [.72, .35, .35]], 5);
  await cargo.save();
}

const egg = model("PowerEggShell");
egg.loft([[-1.3, .22, .22], [-1.1, .65, .65], [-.69, .94, .94],
  [.04, 1, 1], [.61, .77, .77], [1.06, .46, .46], [1.29, .12, .12]], 12);
await egg.save();

const dropper = model("DropperHousing");
dropper.loft([[-1, 2.65, 1.18], [-.63, 3, 1.45], [.38, 3, 1.45], [1, 2.4, 1.1]], 8);
await dropper.save();
