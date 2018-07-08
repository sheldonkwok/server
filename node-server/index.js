const fastify = require("fastify")({
  logger: true
});

// Declare a route
fastify.get("/", function(request, reply) {
  reply.send({ message: "Hello world, I'm a node server!" });
});

// Run the server!
fastify.listen(8081, "::", (err, address) => {
  if (err) throw err;
  fastify.log.info(`server listening on ${address}`);
});
