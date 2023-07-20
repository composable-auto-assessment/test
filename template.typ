#import "style.typ": *
#import "write.typ": *


#let f = "file"
#let g = "model"


#let qr(id, page, active) = {
  if active {
    image("qr/qrcode-" + str(id) + "-" + str(page) + ".png", width: qr_code_size, height: qr_code_size)
  } else {
    square(size: qr_code_size, fill: white, stroke: 0pt)
  }
}

#let sw = 0.50pt
#let case(id, size: 10pt, outset: 0pt, kind: "Unkown") = {
  locate(loc => {
    let sz = size + outset;
    let l = loc.position()
    let bb = (t: kind, p: l.page, at: (x: tocm(l.x), y: tocm(l.y), dx: tocm(size+sw/2), dy: tocm(size+sw/2)))
    [#append(f, ("q", id), bb)
    #square(size: size, outset: outset, stroke: sw + black)]
  })
}

#let bcase = case.with(kind: "Binary")

#let marker(id, size: 5pt, fill: black) = {
  locate(loc => {
    let l = loc.position()
    let bb = (x: tocm(l.x+size), y: tocm(l.y+size))
    [#checked_new_append(f, ("mk", "d"), tocm(size*2))
    #append(f, ("mk", id), bb)
    #square(size: size*2, fill: fill.negate(), stroke: 0pt, inset: 0pt, circle(radius: size, fill: fill, stroke: 0pt))]
  })
}