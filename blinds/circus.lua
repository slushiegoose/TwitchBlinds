local tw_blind = SMODS.Blind {
    key = register_twitch_blind('circus', false),
    dollars = 5,
    mult = 2,
    boss = {
        min = 40,
        max = 40
    },
    pos = { x = 0, y = 10 },
    config = { tw_bl = { in_pool = true } },
    atlas = 'twbl_blind_chips',
    boss_colour = HEX('da2424'),
}

function tw_blind:set_blind(reset, silent)
    if reset then return end
    G.GAME.blind:wiggle()
    local card = create_card('Joker', G.jokers, false, nil, nil, nil, 'j_ring_master', nil)
    card:set_edition({ negative = true }, true)
    card:set_eternal(true)
    card:add_to_deck()
    G.jokers:emplace(card)
end
