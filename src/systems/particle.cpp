#ifdef _WIN32
#  include <GL/gl.h>
#else
#  ifdef __APPLE__
#    include <OpenGL/gl.h>
#  else
#    include <GL/gl.h>
#  endif
#endif

#include <components/particle.h>

#include "particle.h"

void ParticleSystem::update(entityx::EntityManager &entities,
                          entityx::EventManager &events,
                          double dt) {
    for (auto entity : entities.entities_with_components<Particle>()) {
        if (entity.valid()) {
            auto particle = entity.component<Particle>();

            particle->age += dt;
            if (particle->age > particle->duration) {
                entity.destroy();
            }
        }
    }
}

