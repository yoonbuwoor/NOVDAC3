export default async () => {
  return new Response(
    JSON.stringify({
      ok: true,
      service: "DroneAtlas Netlify Functions",
      message: "La fonction fonctionne."
    }),
    {
      status: 200,
      headers: {
        "Content-Type": "application/json; charset=utf-8"
      }
    }
  );
};
