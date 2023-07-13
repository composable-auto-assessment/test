#let wb = state("writebuffer", (:))

// Force an error onto typst
#let fail(err) = {
    (:).at(err)
}

#let jsonify(dict) = {
  let a = ""
  if type(dict) == "dictionary" {
    a += "{" + dict.pairs().map(i => "\"" + str(i.first()) + "\":" + jsonify(i.last())).join(",") + "}"
  } else if type(dict) == "array" {
    a += "[" + dict.map(v => jsonify(v)).join(",") + "]"
  } else {
    a += repr(dict);
  }
  a
}

#let inl(inl) = "\n" + ("    " * inl)
#let jsonify_pretty(dict, depth: 0) = {
  let a = ""
  let s = inl(depth+1)
  if type(dict) == "dictionary" {
    a += "{" + s + dict.pairs().map(i => "\"" + str(i.first()) + "\": " + jsonify_pretty(i.last(), depth: depth + 1)).join("," + s) + inl(depth) + "}"
  } else if type(dict) == "array" {
    a += "[" + s + dict.map(v => jsonify_pretty(v, depth: depth + 1)).join("," + s) + inl(depth) + "]"
  } else {
    a += repr(dict);
  }
  a
}

#let open(file) = {
  return wb.update(x => {
    x.insert("file", (:))
    x
  })
}

#let dict_insert(d, key, value, new: false, check: false) = {
  if type(key) == "array" {
    let c = (d,) // This is a recursion tracker
    // We populate the (unfolded) recursive dict
    for i in range(key.len()-1) {
      let k = key.at(i)
      let kn = key.at(i+1)
      // Create the current entry
      if type(kn) == "string" {
        c.push(c.last().at(k, default: (:)))
      } else if type(kn) == "integer" {
        c.push(c.last().at(k, default: ()))
      }
    }
    if new and key.last() in c.last() {
      if check and c.last().at(key.last()) != value {
        return fail("inconsitent values at" + repr(key))
      }
      // We do not overwrite
      return d
    } 
    //Finalize the URD with the value
    c.push(value)
    // Reconstitute (fold) the dict
    for i in range(c.len()-1, 0, step: -1) {
      let k = key.at(i - 1)
      if k == -1 { //Unordered append
        c.at(i - 1).push(c.at(i))
      } else {
        c.at(i - 1).insert(k, c.at(i))
      }
    }
    c.first()
  } else if type(key) == "string" {
    if new and key in d {
      if check and d.at(key) != value {
        return fail("inconsitent values at: " + key)
      }
      // We do not overwrite
      return d
    }
    d.insert(key, value)
    d
  }
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