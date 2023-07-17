#import "basics.typ": *

#let wb = state("writebuffer", (:))

// Opens a file to the write buffer
#let open(file) = {
  return wb.update(x => {
    x.insert("file", (:))
    x
  })
}

#let append(file, key, value) = {
  wb.update(x => {
    x.insert(file, dict_insert(x.at(file), key, value))
    x
  })
}

#let checked_new_append(file, key, value) = {
  wb.update(x => {
    x.insert(file, dict_insert(x.at(file), key, value, new: true, check: true))
    x
  })
}

#let dump(file) = {
  locate(loc => {
    wb.final(loc).at(file)
  })
}

#let jsondump(file) = {
  locate(loc => {
    let x = wb.final(loc).at(file)
    write(file + ".json", jsonify_pretty(x))
  })
}