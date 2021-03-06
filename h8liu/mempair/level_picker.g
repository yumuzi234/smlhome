const nlevel = 7

const (
    statePicking = 0
    statePicked = 1
    stateDisappearing = 2
    stateDone = 3
)

struct levelPicker {
    level int
    reached int

    state int
    timer time.Timer
}

func (p *levelPicker) init() {
    p.state = statePicking
    p.timer.Clear()
}

func (p *levelPicker) render() {
    var prop table.Prop

    if p.state == statePicking {
        prop.Texts[0] = "Click a number to pick a level."
        for i := 0; i < nlevel; i++ {
            c := &prop.Cards[i]
            c.Visible = true
            c.Face = '1' + char(i)
            if i <= p.reached {
                c.FaceUp = true
            }
        }
    } else if p.state == statePicked {
        c := &prop.Cards[p.level]
        c.Visible = true
        c.Face = '1' + char(p.level)
        c.FaceUp = true
    }

    table.Render(&prop)
}

func (p *levelPicker) waitAWhile() {
    t := time.Now()
    t.Add(&aWhile)
    p.timer.SetDeadline(&t)
}

func (p *levelPicker) dispatch() {
    var s events.Selector
    ev := s.Select(nil, &p.timer)
    if ev == events.Nothing return

    if ev == events.Click {
        if p.state == statePicking {
            what, pos := s.LastClick()
            if what == table.OnCard && pos < nlevel && pos <= p.reached {
                p.state = statePicked
                p.level = pos
                p.waitAWhile()
            }
        }
    } else if ev == events.Timer {
        if p.state == statePicked {
            p.state = stateDisappearing
            p.waitAWhile()
        } else if p.state == stateDisappearing {
            p.state = stateDone
        }
    }
}

func (p *levelPicker) done() bool {
    return p.state == stateDone
}

func (p *levelPicker) reach(i int) {
    if i > p.reached {
        p.reached = i
    }
}

func (p *levelPicker) pick() int {
    p.init()
    p.render()

    for !p.done() {
        p.dispatch()
        p.render()
    }

    fmt.PrintInt(p.level)
    fmt.PrintStr("\n")
    return p.level
}
