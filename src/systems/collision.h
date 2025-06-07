#pragma once

#include <entityx/entityx.h>

class CollisionSystem : public entityx::System<CollisionSystem> {
public:
    void update(entityx::EntityManager &entities,
                entityx::EventManager &events,
                double dt) override;
};
