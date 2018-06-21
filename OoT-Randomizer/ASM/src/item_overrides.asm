inventory_check:
    andi    a0, a0, 0xFF
    li      t0, SAVE_CONTEXT

    beq     a0, 0x8C, @@return ; Deku Nuts (5)
    lbu     v0, 0x75 (t0)

    beq     a0, 0x8D, @@return ; Deku Nuts (10)
    lbu     v0, 0x75 (t0)

    beq     a0, 0x00, @@return ; Deku Stick
    lbu     v0, 0x74 (t0)

    beq     a0, 0x8A, @@return ; Deku Sticks (5)
    lbu     v0, 0x74 (t0)

    beq     a0, 0x8B, @@return ; Deku Sticks (10)
    lbu     v0, 0x74 (t0)

    beq     a0, 0x58, @@return ; Deku Seeds (5)
    li      v0, 0x00

    beq     a0, 0x78, @@return ; Small Magic Jar
    li      v0, 0x00

    beq     a0, 0x79, @@return ; Large Magic Jar
    li      v0, 0x00

    li      v0, 0xFF

@@return:
    jr      ra
    nop

;==================================================================================================

override_object_npc:
    lw      a2, 0x0030 (sp)
    lh      a1, 0x0004 (a2)
    j       override_object
    nop

override_object_chest:
    lw      t9, 0x002C (sp)
    lh      a1, 0x0004 (t9)
    j       override_object
    nop

override_object:
    li      t2, EXTENDED_ITEM_DATA
    lw      t3, ITEM_ROW_IS_EXTENDED (t2)
    beqz    t3, @@return
    nop

    ; Override Object ID
    lhu     a1, ITEM_ROW_OBJECT_ID (t2)

@@return:
    ; Clear any pending special item, now that it's being received
    li      t2, PENDING_SPECIAL_ITEM
    sb      r0, 0x00 (t2)

    jr ra
    nop

;==================================================================================================

override_graphic:
    li      t0, EXTENDED_ITEM_DATA
    lw      t1, ITEM_ROW_IS_EXTENDED (t0)
    beqz    t1, @@return
    nop

    ; Override Graphic ID
    lb      v1, ITEM_ROW_GRAPHIC_ID (t0)

@@return:
    ; Displaced code
    abs     t0, v1
    sb      t0, 0x0852 (a0)
    jr      ra
    nop

;==================================================================================================

override_text:
    lbu     a1, 0x03 (v0) ; Displaced code

    li      t0, EXTENDED_ITEM_DATA
    lw      t1, ITEM_ROW_IS_EXTENDED (t0)
    beqz    t1, @@return
    nop

    ; Override Text ID
    lbu     a1, ITEM_ROW_TEXT_ID (t0)

@@return:
    jr      ra
    nop

;==================================================================================================

override_action:
    ; Displaced code
    lw      v0, 0x24 (sp)
    lbu     a1, 0x0000 (v0)

    li      t0, EXTENDED_ITEM_DATA
    lw      t1, ITEM_ROW_IS_EXTENDED (t0)
    beqz    t1, @@return
    nop

    ; Override Action ID
    lbu     a1, ITEM_ROW_ACTION_ID (t0)

    sw      a0, 0x00 (sp)
    sw      a1, 0x04 (sp)
    sw      a2, 0x08 (sp)
    addiu   sp, sp, -0x18
    sw      ra, 0x10 (sp)

    ; Run effect function
    li      a0, SAVE_CONTEXT
    lbu     a1, ITEM_ROW_EFFECT_ARG1 (t0)
    lbu     a2, ITEM_ROW_EFFECT_ARG2 (t0)
    lw      t1, ITEM_ROW_EFFECT_FN (t0)
    jalr    t1
    nop

    lw      ra, 0x10 (sp)
    addiu   sp, sp, 0x18
    lw      a0, 0x00 (sp)
    lw      a1, 0x04 (sp)
    lw      a2, 0x08 (sp)

@@return:
    jr      ra
    nop

;==================================================================================================

store_item_data_hook:
    sb      a2, 0x0424 (a3) ; Displaced code

    addiu   sp, sp, -0x20
    sw      v0, 0x10 (sp)
    sw      v1, 0x14 (sp)
    sw      ra, 0x18 (sp)

    jal     store_item_data
    nop

    lw      v0, 0x10 (sp)
    lw      v1, 0x14 (sp)
    lw      ra, 0x18 (sp)
    addiu   sp, sp, 0x20
    jr      ra
    nop

;==================================================================================================

store_item_data:
    addiu   sp, sp, -0x18
    sw      ra, 0x10 (sp)

    ; Clear current item data
    li      t0, EXTENDED_ITEM_DATA
    sw      r0, 0x00 (t0)
    sw      r0, 0x04 (t0)
    sw      r0, 0x08 (t0)
    sw      r0, 0x0C (t0)

    li      t0, PLAYER_ACTOR
    lb      t1, 0x0424 (t0) ; t1 = item ID being received
    beqz    t1, @@return
    nop

    abs     a0, t1
    lw      a1, 0x0428 (t0) ; a1 = actor giving the item
    jal     lookup_override ; v0 = new item ID from override
    nop
    bltz    v0, @@return
    nop

    ori     a0, v0, 0
    jal     resolve_extended_item ; v0 = resolved item ID, v1 = ITEM_TABLE entry
    nop
    beqz    v1, @@update_base_game
    nop

    ; Store extended item data
    li      t0, EXTENDED_ITEM_DATA
    lw      t1, 0x00 (v1)
    sw      t1, 0x00 (t0)
    lw      t1, 0x04 (v1)
    sw      t1, 0x04 (t0)
    lw      t1, 0x08 (v1)
    sw      t1, 0x08 (t0)
    ; Mark the extended item data as active
    li      t1, 1
    sw      t1, ITEM_ROW_IS_EXTENDED (t0)
    ; Load the base item to be stored back in the player actor / chest
    lbu     v0, ITEM_ROW_BASE_ITEM (v1)

@@update_base_game:
    li      t0, PLAYER_ACTOR
    ; If the giving actor is a chest, update it with new contents
    lw      t1, 0x0428 (t0)
    lhu     t2, 0x00 (t1)
    bne     t2, 0x000A, @@not_chest
    nop
    lhu     t2, 0x1C (t1)
    andi    t2, t2, 0xF01F
    sll     t3, v0, 5
    or      t2, t2, t3
    sh      t2, 0x1C (t1)
@@not_chest:
    ; Update player actor
    lb      t1, 0x0424 (t0)
    bgez    t1, @@not_negative
    nop
    ; The input was negative (item is in a nearby chest), so make the result negative
    subu    v0, r0, v0
@@not_negative:
    sb      v0, 0x0424 (t0)

@@return:
    lw      ra, 0x10 (sp)
    addiu   sp, sp, 0x18
    jr      ra
    nop

;==================================================================================================

lookup_override:
    ; a0 = item ID being received
    ; a1 = actor giving the item

    addiu   sp, sp, -0x18
    sw      ra, 0x10 (sp)

    jal     get_override_search_key
    nop
    beq     v0, -1, @@return
    nop

    ori     a0, v0, 0
    jal     scan_override_table
    nop

@@return:
    lw      ra, 0x10 (sp)
    addiu   sp, sp, 0x18
    jr      ra
    nop

;==================================================================================================

get_override_search_key:
    ; a0 = item ID being received
    ; a1 = actor giving the item

    ; Load the current scene number
    li      v0, GLOBAL_CONTEXT
    lhu     v0, 0xA4 (v0)

    li      t0, 0x00 ; t0 = override type
    ori     t1, a0, 0 ; t1 = override ID
    lhu     t2, 0x00 (a1) ; t2 = actor ID

    bne     t2, 0x000A, @@not_chest
    nop
    lhu     t3, 0x1C (a1)
    bne     v0, 0x10, @@valid_chest
    nop
    ; Current scene is the treasure chest game.
    ; Don't apply the override if the chest contains 0x75 (Winner! purple rupee)
    andi    t4, t3, (0x7F << 5)
    bne     t4, (0x75 << 5), @@valid_chest
    nop
    li      v0, -1
    b       @@return
    nop
@@valid_chest:
    li      t0, 0x01
    andi    t1, t3, 0x1F ; t1 = chest flag
@@not_chest:

    bne     t2, 0x0015, @@not_collectable
    nop
    beq     a0, 0x3E, @@valid_collectable
    nop
    beq     a0, 0x42, @@valid_collectable
    nop
    li      v0, -1
    b       @@return
    nop
@@valid_collectable:
    li      t0, 0x02
    lbu     t1, 0x0141 (a1) ; t1 = collectable flag
@@not_collectable:

    ; Construct ID used to search the override table
    ; v0 = (scene << 16) | (override_type << 8) | override_id
    sll     v0, v0, 8
    or      v0, v0, t0
    sll     v0, v0, 8
    or      v0, v0, t1

@@return:
    jr      ra
    nop

;==================================================================================================

scan_override_table:
    ; a0 = override search key

    li      v0, -1

    ; Look up override
    li      t0, (ITEM_OVERRIDES - 0x04)
@@lookup_loop:
    addiu   t0, t0, 0x04
    lw      t1, 0x00 (t0) ; t1 = override entry
    beqz    t1, @@return ; Reached end of override table
    nop
    srl     t2, t1, 8 ; t2 = override key
    bne     t2, a0, @@lookup_loop
    nop

    andi    v0, t1, 0xFF ; v0 = found item ID

@@return:
    jr      ra
    nop

;==================================================================================================

resolve_extended_item:
    ; a0 = input item ID

    addiu   sp, sp, -0x20
    sw      s0, 0x10 (sp)
    sw      s1, 0x14 (sp)
    sw      ra, 0x18 (sp)

    ori     v0, a0, 0 ; Return resolved item ID in v0

@@loop:
    ori     s0, v0, 0
    addiu   t0, s0, -0x80 ; t0 = index into extended ITEM_TABLE
    bltz    t0, @@not_extended ; Item IDs in range 0x00 - 0x7F are not extended
    nop
    ; Load table entry
    li      s1, ITEM_TABLE
    li      t1, ITEM_TABLE_ROW_SIZE
    mult    t0, t1
    mflo    t0
    addu    s1, s1, t0 ; s1 = pointer to table entry
    ; Check whether this item will upgrade into another item
    ; Conventions for upgrade functions:
    ; - They receive a pointer to the save context in a0
    ; - They receive their item ID in a1
    ; - They store their result in v0
    li      a0, SAVE_CONTEXT
    ori     a1, s0, 0
    lw      t0, ITEM_ROW_UPGRADE_FN (s1)
    jalr    t0 ; v0 = upgraded item ID
    nop
    ; If the upgrade function returned a new item ID, start resolution over again
    bne     v0, s0, @@loop
    nop

    ori     v1, s1, 0 ; Return pointer to ITEM_TABLE entry in v1
    b       @@return
    nop

@@not_extended:
    li      v1, 0

@@return:
    lw      s0, 0x10 (sp)
    lw      s1, 0x14 (sp)
    lw      ra, 0x18 (sp)
    addiu   sp, sp, 0x20
    jr      ra
    nop
