#import "template.typ": *

#let meta = json("meta.json")
#let source = json("source.json")
#set heading(numbering:"1.")
#set page(
  footer: [
    #place(center)[
      #counter(page).display("1 / 1", both: true)
    ]
    #place(right)[id: #source.examId]
  ],
  foreground: [         // Prevent repeats!!
    #place(bottom+left, dx : 10pt, dy : -10pt, marker("m"))
    #place(top+left, dx : 10pt, dy : 10pt, marker("l"))
    #place(bottom+right, dx : -10pt, dy : -10pt, marker("s"))
    #place(top+right, dx : -10pt, dy : 10pt,
      layout(size => {
        locate(loc => {
          let i = counter(page).at(loc).at(0)
          let l = loc.position()
          qr(i, meta.active)
          append(f, "qr", (x: tocm(l.x), y: tocm(l.y), dx: tocm(qr_code_size), dy: tocm(qr_code_size)))
          append(f, ("md", "w"), tocm(size.width))
          append(f, ("md", "h"), tocm(size.height))
          append(f, ("md", "n"), counter(page).final(loc).at(0))
        })
      })
    )
  ]
)
#open(f)


/* Grille numéro étudiant 
La fonction id_etudiant génère une grille de 8 colonnes et de 10 lignes */

#let id_etudiant() = [
  #let colonne_cases() = {
    let i = 0
    while i < 10 {
      square(size: 3pt, outset: 4pt)
      i=i+1
    }
  }

  #let colonne_chiffre() = {
    let i = 0
    while i < 10 {
      [#i]
      linebreak() 
      v(-4.5pt)
      i=i+1
    }
  }
  #box()[
      #columns(9, gutter: -300pt)[
      #colonne_chiffre()
      #colbreak()
      #let n=0
      #while n < 8{
        colonne_cases()
        colbreak()
        n=n+1
      } 
    ]
  ]
]


/* Logo
- Importer un logo sous l'appelation "Logo.png"
*/

#let logo(taille)=[
  #if taille == "grand"{
    image("Logo.png", width: 100%)
  }
  else if taille == "moyen grand"{
    image("Logo.png", width: 75%)
  }
  else if taille == "moyen"{
    image("Logo.png", width: 50%)
  }
  else if taille == "moyen petit"{
    image("Logo.png", width: 25%)
  }
  else if taille == "petit"{
    image("Logo.png", width: 0%)
  }
  
]
/* Une fonction pour tout
- type_q : type de la question (multiple true false, 1 parm N...)
- type_a : type d'affichage : afficher les réponses en sautant une ligne = "saut"
                              à la suite = "suite"
- q : question
*/

#let affichage_question(type_q,type_a, q)= {
  /* type d'affichage */
  let affichage_defaut(type_a, q) = {
    if type_a == "a_la_suite"{
     columns( q.numberOfAnswers, gutter : -200pt)[
        #let nOA = q.numberOfAnswers
        #align(center)[
          /* Pour chaque réponse */
          #for a in q.answers {
            block()[#v(5pt)#a.answerLabel
            #align(center)[#box(bcase(a.answerId, size : 10pt))]
            ]
            if nOA > 1 {
              colbreak()
            }
            nOA=nOA - 1
        }
        #v(20pt)//espacement après exo
        ]]
    } else{
      for a in q.answers [
          #box(bcase(a.answerId, size : 10pt)) #h(8pt) #a.answerLabel
        #v(2pt)
      ]
       v(10pt)//espacement après exo
    }
  }
  let affichage_TF(type_a, q) = {
    {
      for a in q.answers [
          #box(width: 25pt, columns([#bcase(a.answerId + "T", size : 10pt)#colbreak() #bcase(a.answerId + "F", size : 10pt)])) #h(8pt) #a.answerLabel
        #v(2pt) // OMG !
      ]
       v(10pt)//espacement après exo
    }
  }
  
  /* type de question */
  if type_q == "MCQ"{
    [_plusieurs réponses peuvent être justes_
  
  ]
    affichage_defaut(type_a, q)
  }
  else if type_q == "1parmiN"{
    [_une seule réponse est juste_
  
  ]
    affichage_defaut(type_a, q)
  }
   else if type_q == "multipleTF"{
    [_une seule réponse par question_
  
  ]
    affichage_TF(type_a, q)
  }

}

/* Presentation() affiche les premiers éléments indispendables pour identifier une copie */

#let presentation(exam) = [
  #place(top+left, dx : 0pt, dy : -10pt)[#logo("moyen petit")]
  #place(top+right, dx : 10pt, dy : 10pt)[Numéro Étudiant #v(0pt) #id_etudiant()]
  #place(top+left, dx : 10pt, dy : 1.8cm)[
  #rect(width: 7cm, height: 3cm, inset: 11pt)[Nom : #v(15pt) Prenom :]]
  #v(7cm)
  // Espace identifiant étudiant
  #underline[*#align(center, text(size : 15pt, exam.title))*] //Titre
]

#let forecast(exam) = [    
  #presentation(exam)
  /* Parcourir chaque exercice */
  #for ex in exam.exercises {
    block()
      [#align(center)[#rect[= #upper[#text(size : 13pt, "Exercice")]]]//Titre de l'exercice
      #align(center)[#ex.eSText] //Énoncé de l'exercice
      #v(15pt)
      /* Parcourir chaque question */
      #for q in ex.questions {
          [== #q.qStatement]
          affichage_question(q.questionType, "saut", q)
      }
      ] 
  }
]

#append(f, ("md", "id"), source.examId)
#if meta.active {
  append(f, ("md", "hash"), meta.hash)
} else {
  append(f, ("md", "hash"), (0,))
}

#forecast(json("source.json"))

#jsondump(f)