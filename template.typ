#import "write.typ": *

#let positions = state("p", "")

#let tocm(size) = {
  return calc.round(size/1cm, digits: 2)
}
#let f = "file"

#let x = counter("gay")
#let sw = 0.50pt
#let case(id, size: 10pt, outset: 0pt) = {
  locate(loc => {
    let l = loc.position()
    let bb = (id: id, p: l.page, at: (x: tocm(l.x), y: tocm(l.y), dx: tocm(size+sw/2), dy: tocm(size+sw/2)))
    [#append(f, ("q", id), bb)
    #square(size: size, outset: outset, stroke: sw + black)]
  })
}

#let marker(id, size: 5pt, fill: black) = {
  locate(loc => {
    let l = loc.position()
    let bb = (x: tocm(l.x+size/2), y: tocm(l.y+size/2))
    [#checked_new_append(f, ("mk", "d"), tocm(size*2))
    #append(f, ("mk", id), bb)
    #square(size: size*2, fill: fill.negate(), stroke: 0pt, inset: 0pt, circle(radius: size, fill: fill, stroke: 0pt))]
  })
}