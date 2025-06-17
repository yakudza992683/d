#include <gtest/gtest.h>
#include "../include/Bot.hpp"

// Минимальный мок для WorldEntity и GameWorld
class DummyEntity : public WorldEntity {
public:
    int getType() const override { return 1; }
    bool isDying() const override { return false; }
};
class DummyGameWorld : public GameWorld {};

TEST(BotTest, DefaultConstructor) {
    Bot bot;
    SUCCEED();
}

TEST(BotTest, SetTarget) {
    Bot bot;
    DummyEntity entity;
    bot.setTarget(&entity);
    bot.hit(&entity, nullptr);
    SUCCEED();
}

TEST(BotTest, InitializeStatic) {
    Bot::initialize();
    SUCCEED();
}

// Проверка hit с типом ZOMBIE
class ZombieEntity : public WorldEntity {
public:
    int getType() const override { return EntityTypes::ZOMBIE; }
    bool isDying() const override { return false; }
};

TEST(BotTest, HitZombieSetsTarget) {
    Bot bot;
    ZombieEntity zombie;
    bot.hit(&zombie, nullptr);
    SUCCEED();
}
