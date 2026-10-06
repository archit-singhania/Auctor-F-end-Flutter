from pathlib import Path
p=Path('web/landing/index.html');s=p.read_text();s=s.replace('</style>', '''/* Provenance arrives in one quiet sequence; navigation remains immediately usable. */
@keyframes evidence-settle{from{opacity:.25;transform:translateY(12px)}to{opacity:1;transform:none}}
.hero>div:first-child{animation:evidence-settle 240ms cubic-bezier(.2,.7,.3,1) both}
.hero .path{animation:evidence-settle 280ms cubic-bezier(.2,.7,.3,1) both}
.feature{transition:border-color 180ms ease,box-shadow 180ms ease}
.feature:hover{border-color:var(--jade);box-shadow:0 12px 30px #112e3714}
@media(prefers-reduced-motion:reduce){.hero>div,.hero .path{animation:none}.feature{transition:none}}
</style>''');p.write_text(s)
