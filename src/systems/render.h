#pragma once

#include <entityx/entityx.h>

class RenderSystem : public entityx::System<RenderSystem> {
public:
    void update(entityx::EntityManager &entities,
                entityx::EventManager &events,
                double dt) override;

        int width;
        int height;
};

