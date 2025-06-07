#pragma once

#include <entityx/entityx.h>

class ParticleSystem : public entityx::System<ParticleSystem> {
public:
    void update(entityx::EntityManager &entities,
                entityx::EventManager &events,
                double dt) override;
};

