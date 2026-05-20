import React, { useEffect, useMemo, useState } from 'react';
import {
  AlertCircle,
  ArrowLeft,
  ArrowRight,
  BookOpen,
  CheckCircle2,
  Clock3,
  Flag,
  History,
  Eye,
  LogIn,
  Menu,
  RotateCcw,
  Send,
  Trash2,
  X,
} from 'lucide-react';
import { examConfig, questions } from './questions.js';

const HISTORY_STORAGE_KEY = 'cbt-utbk-attempt-history';

const screen = {
  LOGIN: 'login',
  INSTRUCTIONS: 'instructions',
  EXAM: 'exam',
  RESULT: 'result',
  REVIEW: 'review',
  HISTORY: 'history',
};

function formatTime(totalSeconds) {
  const hours = Math.floor(totalSeconds / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const seconds = totalSeconds % 60;
  return [hours, minutes, seconds].map((value) => String(value).padStart(2, '0')).join(':');
}

function formatDateTime(value) {
  return new Intl.DateTimeFormat('id-ID', {
    dateStyle: 'medium',
    timeStyle: 'short',
  }).format(new Date(value));
}

function readAttemptHistory() {
  try {
    return JSON.parse(window.localStorage.getItem(HISTORY_STORAGE_KEY) || '[]');
  } catch {
    return [];
  }
}

function App() {
  const [page, setPage] = useState(screen.LOGIN);
  const [participant, setParticipant] = useState({ name: '', number: '' });
  const [currentIndex, setCurrentIndex] = useState(0);
  const [answers, setAnswers] = useState({});
  const [doubtful, setDoubtful] = useState({});
  const [secondsLeft, setSecondsLeft] = useState(examConfig.durationMinutes * 60);
  const [showSubmitConfirm, setShowSubmitConfirm] = useState(false);
  const [showMobilePanel, setShowMobilePanel] = useState(false);
  const [result, setResult] = useState(null);
  const [examStartedAt, setExamStartedAt] = useState(null);
  const [attemptHistory, setAttemptHistory] = useState(() => readAttemptHistory());
  const [selectedAttempt, setSelectedAttempt] = useState(null);

  const currentQuestion = questions[currentIndex];
  const answeredCount = Object.keys(answers).length;
  const doubtfulCount = Object.values(doubtful).filter(Boolean).length;

  useEffect(() => {
    if (page !== screen.EXAM) return undefined;
    if (secondsLeft <= 0) {
      finishExam();
      return undefined;
    }
    const interval = window.setInterval(() => {
      setSecondsLeft((value) => Math.max(value - 1, 0));
    }, 1000);
    return () => window.clearInterval(interval);
  }, [page, secondsLeft]);

  const summary = useMemo(() => {
    return questions.reduce(
      (acc, question) => {
        const chosen = answers[question.id];
        if (!chosen) {
          acc.unanswered += 1;
        } else if (chosen === question.answer) {
          acc.correct += 1;
        } else {
          acc.wrong += 1;
        }
        return acc;
      },
      { correct: 0, wrong: 0, unanswered: 0 },
    );
  }, [answers]);

  function startInstructions(event) {
    event.preventDefault();
    setPage(screen.INSTRUCTIONS);
  }

  function startExam() {
    setPage(screen.EXAM);
    setSecondsLeft(examConfig.durationMinutes * 60);
    setExamStartedAt(new Date().toISOString());
  }

  function chooseAnswer(optionKey) {
    setAnswers((previous) => ({ ...previous, [currentQuestion.id]: optionKey }));
  }

  function toggleDoubtful() {
    setDoubtful((previous) => ({ ...previous, [currentQuestion.id]: !previous[currentQuestion.id] }));
  }

  function goToQuestion(index) {
    setCurrentIndex(index);
    setShowMobilePanel(false);
  }

  function finishExam() {
    const finishedAt = new Date().toISOString();
    const finalSummary = questions.reduce(
      (acc, question) => {
        const chosen = answers[question.id];
        if (!chosen) {
          acc.unanswered += 1;
        } else if (chosen === question.answer) {
          acc.correct += 1;
        } else {
          acc.wrong += 1;
        }
        return acc;
      },
      { correct: 0, wrong: 0, unanswered: 0 },
    );

    const finalResult = {
      ...finalSummary,
      score: Math.round((finalSummary.correct / questions.length) * 100),
      total: questions.length,
    };
    const historyItem = {
      id: `${Date.now()}-${Math.random().toString(16).slice(2)}`,
      participant: { ...participant },
      examTitle: examConfig.title,
      startedAt: examStartedAt || finishedAt,
      finishedAt,
      durationSeconds: Math.max(examConfig.durationMinutes * 60 - secondsLeft, 0),
      answers: { ...answers },
      doubtful: { ...doubtful },
      result: finalResult,
    };
    const nextHistory = [historyItem, ...attemptHistory].slice(0, 200);

    window.localStorage.setItem(HISTORY_STORAGE_KEY, JSON.stringify(nextHistory));
    setAttemptHistory(nextHistory);
    setResult(finalResult);
    setShowSubmitConfirm(false);
    setPage(screen.RESULT);
  }

  function clearHistory() {
    const confirmed = window.confirm('Hapus semua histori pengerjaan peserta di browser ini?');
    if (!confirmed) return;
    window.localStorage.removeItem(HISTORY_STORAGE_KEY);
    setAttemptHistory([]);
    setSelectedAttempt(null);
  }

  function restart() {
    setPage(screen.LOGIN);
    setParticipant({ name: '', number: '' });
    setCurrentIndex(0);
    setAnswers({});
    setDoubtful({});
    setSecondsLeft(examConfig.durationMinutes * 60);
    setExamStartedAt(null);
    setShowSubmitConfirm(false);
    setShowMobilePanel(false);
    setResult(null);
  }

  if (page === screen.LOGIN) {
    return (
      <Shell centered>
        <section className="w-full max-w-md rounded-lg border border-slate-200 bg-white p-6 shadow-soft sm:p-8">
          <div className="mb-8">
            <div className="mb-5 flex h-12 w-12 items-center justify-center rounded-md bg-blue-600 text-white">
              <BookOpen size={26} aria-hidden="true" />
            </div>
            <p className="text-sm font-semibold uppercase tracking-[0.18em] text-blue-700">CBT UTBK</p>
            <h1 className="mt-2 text-2xl font-bold text-slate-950 sm:text-3xl">Login Peserta</h1>
            <p className="mt-2 text-sm leading-6 text-slate-600">
              Masukkan identitas peserta untuk masuk ke halaman instruksi ujian.
            </p>
          </div>

          <form className="space-y-4" onSubmit={startInstructions}>
            <label className="block">
              <span className="text-sm font-semibold text-slate-700">Nama peserta</span>
              <input
                required
                value={participant.name}
                onChange={(event) => setParticipant((value) => ({ ...value, name: event.target.value }))}
                className="mt-2 w-full rounded-md border border-slate-300 px-4 py-3 text-slate-900 outline-none transition focus:border-blue-600 focus:ring-4 focus:ring-blue-100"
                placeholder="Contoh: Alya Putri"
              />
            </label>
            <label className="block">
              <span className="text-sm font-semibold text-slate-700">Nomor peserta</span>
              <input
                required
                value={participant.number}
                onChange={(event) => setParticipant((value) => ({ ...value, number: event.target.value }))}
                className="mt-2 w-full rounded-md border border-slate-300 px-4 py-3 text-slate-900 outline-none transition focus:border-blue-600 focus:ring-4 focus:ring-blue-100"
                placeholder="Contoh: 26050123"
              />
            </label>
            <button className="flex w-full items-center justify-center gap-2 rounded-md bg-blue-700 px-4 py-3 font-semibold text-white transition hover:bg-blue-800 focus:outline-none focus:ring-4 focus:ring-blue-200">
              <LogIn size={19} aria-hidden="true" />
              Masuk
            </button>
            <button
              type="button"
              onClick={() => setPage(screen.HISTORY)}
              className="flex w-full items-center justify-center gap-2 rounded-md border border-slate-300 bg-white px-4 py-3 font-semibold text-slate-800 transition hover:bg-slate-50 focus:outline-none focus:ring-4 focus:ring-blue-100"
            >
              <History size={19} aria-hidden="true" />
              Histori Peserta
            </button>
          </form>
        </section>
      </Shell>
    );
  }

  if (page === screen.HISTORY) {
    return (
      <Shell>
        <main className="mx-auto min-h-screen w-full max-w-7xl px-4 py-6 sm:py-8">
          <section className="rounded-lg border border-slate-200 bg-white shadow-soft">
            <div className="flex flex-col gap-4 border-b border-slate-200 p-5 sm:flex-row sm:items-center sm:justify-between sm:p-6">
              <div>
                <p className="text-sm font-semibold text-blue-700">Admin</p>
                <h1 className="mt-2 text-2xl font-bold text-slate-950">Histori Pengerjaan Peserta</h1>
                <p className="mt-1 text-sm text-slate-600">
                  Tersimpan lokal di browser ini. Total percobaan: {attemptHistory.length}
                </p>
              </div>
              <div className="flex flex-col gap-2 sm:flex-row">
                <button
                  onClick={() => setPage(screen.LOGIN)}
                  className="flex items-center justify-center gap-2 rounded-md border border-slate-300 bg-white px-4 py-3 font-semibold text-slate-800 transition hover:bg-slate-50"
                >
                  <ArrowLeft size={18} aria-hidden="true" />
                  Kembali
                </button>
                <button
                  onClick={clearHistory}
                  disabled={attemptHistory.length === 0}
                  className="flex items-center justify-center gap-2 rounded-md border border-red-200 bg-red-50 px-4 py-3 font-semibold text-red-700 transition hover:bg-red-100 disabled:cursor-not-allowed disabled:opacity-45"
                >
                  <Trash2 size={18} aria-hidden="true" />
                  Hapus Histori
                </button>
              </div>
            </div>

            {attemptHistory.length === 0 ? (
              <div className="p-8 text-center">
                <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-md bg-slate-100 text-slate-500">
                  <History size={24} aria-hidden="true" />
                </div>
                <h2 className="mt-4 text-lg font-bold text-slate-950">Belum ada histori</h2>
                <p className="mt-2 text-sm text-slate-600">Data akan muncul otomatis setelah peserta submit ujian.</p>
              </div>
            ) : (
              <div className="grid gap-0 lg:grid-cols-[420px_1fr]">
                <div className="border-b border-slate-200 lg:border-b-0 lg:border-r">
                  <div className="max-h-[calc(100vh-180px)] overflow-auto p-4 scrollbar-thin">
                    <div className="space-y-3">
                      {attemptHistory.map((attempt) => {
                        const active = selectedAttempt?.id === attempt.id;
                        return (
                          <button
                            key={attempt.id}
                            onClick={() => setSelectedAttempt(attempt)}
                            className={`w-full rounded-lg border p-4 text-left transition ${
                              active
                                ? 'border-blue-500 bg-blue-50'
                                : 'border-slate-200 bg-white hover:border-blue-200 hover:bg-slate-50'
                            }`}
                          >
                            <div className="flex items-start justify-between gap-3">
                              <div className="min-w-0">
                                <p className="truncate font-bold text-slate-950">{attempt.participant.name}</p>
                                <p className="mt-1 truncate text-sm text-slate-600">No. {attempt.participant.number}</p>
                              </div>
                              <span className="rounded-md bg-blue-700 px-3 py-1 text-sm font-bold text-white">
                                {attempt.result.score}
                              </span>
                            </div>
                            <div className="mt-3 grid grid-cols-3 gap-2 text-center text-xs">
                              <MiniStat label="Benar" value={attempt.result.correct} />
                              <MiniStat label="Salah" value={attempt.result.wrong} />
                              <MiniStat label="Kosong" value={attempt.result.unanswered} />
                            </div>
                            <p className="mt-3 text-xs text-slate-500">{formatDateTime(attempt.finishedAt)}</p>
                          </button>
                        );
                      })}
                    </div>
                  </div>
                </div>

                <div className="min-w-0">
                  {selectedAttempt ? (
                    <HistoryDetail attempt={selectedAttempt} />
                  ) : (
                    <div className="flex min-h-[420px] items-center justify-center p-8 text-center">
                      <div>
                        <div className="mx-auto flex h-12 w-12 items-center justify-center rounded-md bg-blue-50 text-blue-700">
                          <Eye size={24} aria-hidden="true" />
                        </div>
                        <h2 className="mt-4 text-lg font-bold text-slate-950">Pilih peserta</h2>
                        <p className="mt-2 text-sm text-slate-600">Klik salah satu histori di kiri untuk melihat rincian jawaban.</p>
                      </div>
                    </div>
                  )}
                </div>
              </div>
            )}
          </section>
        </main>
      </Shell>
    );
  }

  if (page === screen.INSTRUCTIONS) {
    return (
      <Shell>
        <main className="mx-auto flex min-h-screen w-full max-w-5xl items-center px-4 py-8">
          <section className="w-full rounded-lg border border-slate-200 bg-white shadow-soft">
            <div className="border-b border-slate-200 p-5 sm:p-7">
              <p className="text-sm font-semibold text-blue-700">{examConfig.subject}</p>
              <h1 className="mt-2 text-2xl font-bold text-slate-950 sm:text-3xl">{examConfig.title}</h1>
              <div className="mt-4 grid gap-3 text-sm text-slate-600 sm:grid-cols-3">
                <Info label="Peserta" value={participant.name} />
                <Info label="Nomor" value={participant.number} />
                <Info label="Durasi" value={`${examConfig.durationMinutes} menit`} />
              </div>
            </div>
            <div className="grid gap-6 p-5 sm:p-7 lg:grid-cols-[1fr_280px]">
              <div>
                <h2 className="text-lg font-bold text-slate-950">Instruksi Ujian</h2>
                <ol className="mt-4 space-y-3 text-sm leading-6 text-slate-700">
                  <li>1. Bacalah setiap soal dengan teliti sebelum memilih jawaban.</li>
                  <li>2. Pilih satu jawaban dari opsi A, B, C, D, atau E.</li>
                  <li>3. Gunakan tombol ragu-ragu untuk menandai soal yang ingin ditinjau ulang.</li>
                  <li>4. Nomor soal berwarna biru berarti sudah dijawab, kuning berarti ragu-ragu, dan putih berarti belum dijawab.</li>
                  <li>5. Ujian akan otomatis selesai ketika timer mencapai 00:00:00.</li>
                </ol>
              </div>
              <aside className="rounded-lg border border-blue-100 bg-blue-50 p-5">
                <div className="flex items-center gap-3 text-blue-900">
                  <Clock3 size={22} aria-hidden="true" />
                  <div>
                    <p className="text-sm font-semibold">Waktu tersedia</p>
                    <p className="text-2xl font-bold">{examConfig.durationMinutes}:00</p>
                  </div>
                </div>
                <button
                  onClick={startExam}
                  className="mt-6 flex w-full items-center justify-center gap-2 rounded-md bg-blue-700 px-4 py-3 font-semibold text-white transition hover:bg-blue-800 focus:outline-none focus:ring-4 focus:ring-blue-200"
                >
                  Mulai Ujian
                  <ArrowRight size={18} aria-hidden="true" />
                </button>
              </aside>
            </div>
          </section>
        </main>
      </Shell>
    );
  }

  if (page === screen.RESULT && result) {
    return (
      <Shell centered>
        <section className="w-full max-w-3xl rounded-lg border border-slate-200 bg-white p-6 shadow-soft sm:p-8">
          <div className="flex flex-col gap-5 border-b border-slate-200 pb-6 sm:flex-row sm:items-center sm:justify-between">
            <div>
              <p className="text-sm font-semibold text-blue-700">Hasil Ujian</p>
              <h1 className="mt-2 text-2xl font-bold text-slate-950 sm:text-3xl">{participant.name}</h1>
              <p className="mt-1 text-sm text-slate-600">Nomor peserta: {participant.number}</p>
            </div>
            <div className="rounded-lg bg-blue-700 px-6 py-4 text-center text-white">
              <p className="text-sm font-semibold text-blue-100">Skor</p>
              <p className="text-4xl font-bold">{result.score}</p>
            </div>
          </div>
          <div className="mt-6 grid gap-3 sm:grid-cols-4">
            <ResultCard label="Benar" value={result.correct} tone="green" />
            <ResultCard label="Salah" value={result.wrong} tone="red" />
            <ResultCard label="Tidak Dijawab" value={result.unanswered} tone="slate" />
            <ResultCard label="Total Soal" value={result.total} tone="blue" />
          </div>
          <div className="mt-7 flex flex-col gap-3 sm:flex-row">
            <button
              onClick={() => setPage(screen.REVIEW)}
              className="flex w-full items-center justify-center gap-2 rounded-md bg-blue-700 px-4 py-3 font-semibold text-white transition hover:bg-blue-800 focus:outline-none focus:ring-4 focus:ring-blue-200 sm:w-auto"
            >
              <CheckCircle2 size={18} aria-hidden="true" />
              Lihat Koreksi Jawaban
            </button>
            <button
              onClick={restart}
              className="flex w-full items-center justify-center gap-2 rounded-md border border-slate-300 bg-white px-4 py-3 font-semibold text-slate-800 transition hover:bg-slate-50 focus:outline-none focus:ring-4 focus:ring-blue-100 sm:w-auto"
            >
              <RotateCcw size={18} aria-hidden="true" />
              Ulangi Simulasi
            </button>
          </div>
        </section>
      </Shell>
    );
  }

  if (page === screen.REVIEW && result) {
    return (
      <Shell>
        <main className="mx-auto min-h-screen w-full max-w-6xl px-4 py-6 sm:py-8">
          <section className="rounded-lg border border-slate-200 bg-white shadow-soft">
            <div className="flex flex-col gap-4 border-b border-slate-200 p-5 sm:flex-row sm:items-center sm:justify-between sm:p-6">
              <div>
                <p className="text-sm font-semibold text-blue-700">Koreksi Jawaban</p>
                <h1 className="mt-2 text-2xl font-bold text-slate-950">Rincian Hasil Ujian</h1>
                <p className="mt-1 text-sm text-slate-600">
                  {participant.name} - Skor {result.score} - {result.correct} benar, {result.wrong} salah, {result.unanswered} kosong
                </p>
              </div>
              <div className="flex flex-col gap-2 sm:flex-row">
                <button
                  onClick={() => setPage(screen.RESULT)}
                  className="flex items-center justify-center gap-2 rounded-md border border-slate-300 bg-white px-4 py-3 font-semibold text-slate-800 transition hover:bg-slate-50"
                >
                  <ArrowLeft size={18} aria-hidden="true" />
                  Kembali ke Hasil
                </button>
                <button
                  onClick={restart}
                  className="flex items-center justify-center gap-2 rounded-md bg-blue-700 px-4 py-3 font-semibold text-white transition hover:bg-blue-800"
                >
                  <RotateCcw size={18} aria-hidden="true" />
                  Ulangi
                </button>
              </div>
            </div>

            <div className="grid gap-3 border-b border-slate-200 bg-slate-50 p-4 sm:grid-cols-3 sm:p-6">
              <ReviewLegend tone="green" label="Benar" value={result.correct} />
              <ReviewLegend tone="red" label="Salah" value={result.wrong} />
              <ReviewLegend tone="slate" label="Tidak dijawab" value={result.unanswered} />
            </div>

            <div className="space-y-4 p-4 sm:p-6">
              {questions.map((question, index) => {
                const chosen = answers[question.id];
                const isCorrect = chosen === question.answer;
                const isUnanswered = !chosen;
                const statusLabel = isUnanswered ? 'Tidak dijawab' : isCorrect ? 'Benar' : 'Salah';
                const statusClass = isUnanswered
                  ? 'border-slate-200 bg-slate-100 text-slate-700'
                  : isCorrect
                    ? 'border-green-200 bg-green-50 text-green-800'
                    : 'border-red-200 bg-red-50 text-red-800';

                return (
                  <article key={question.id} className="rounded-lg border border-slate-200 bg-white p-4 sm:p-5">
                    <div className="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
                      <div className="min-w-0">
                        <div className="flex flex-wrap items-center gap-2">
                          <span className="rounded-md bg-slate-900 px-2.5 py-1 text-sm font-bold text-white">Soal {index + 1}</span>
                          <span className={`rounded-md border px-2.5 py-1 text-sm font-bold ${statusClass}`}>{statusLabel}</span>
                        </div>
                        <h2 className="mt-3 text-base font-bold leading-7 text-slate-950">{question.text}</h2>
                      </div>
                    </div>

                    {question.image ? (
                      <img
                        src={question.image}
                        alt={`Gambar soal ${index + 1}`}
                        className="mt-4 max-h-64 w-full rounded-md border border-slate-200 object-contain"
                      />
                    ) : null}

                    <div className="mt-4 grid gap-3 lg:grid-cols-2">
                      {Object.entries(question.options).map(([key, value]) => {
                        const selected = chosen === key;
                        const correct = question.answer === key;
                        const optionClass = correct
                          ? 'border-green-300 bg-green-50 text-green-900'
                          : selected
                            ? 'border-red-300 bg-red-50 text-red-900'
                            : 'border-slate-200 bg-white text-slate-700';

                        return (
                          <div key={key} className={`flex items-start gap-3 rounded-md border p-3 ${optionClass}`}>
                            <span
                              className={`flex h-8 w-8 shrink-0 items-center justify-center rounded-md text-sm font-bold ${
                                correct
                                  ? 'bg-green-700 text-white'
                                  : selected
                                    ? 'bg-red-700 text-white'
                                    : 'bg-slate-100 text-slate-700'
                              }`}
                            >
                              {key}
                            </span>
                            <div className="min-w-0 flex-1">
                              <p className="text-sm leading-6">{value}</p>
                              {correct ? <p className="mt-1 text-xs font-bold text-green-700">Jawaban benar</p> : null}
                              {selected && !correct ? <p className="mt-1 text-xs font-bold text-red-700">Jawaban peserta</p> : null}
                            </div>
                          </div>
                        );
                      })}
                    </div>

                    <div className="mt-4 rounded-md bg-slate-50 p-3 text-sm leading-6 text-slate-700">
                      <p>
                        Jawaban peserta:{' '}
                        <span className="font-bold text-slate-950">
                          {chosen ? `${chosen}. ${question.options[chosen]}` : 'Tidak dijawab'}
                        </span>
                      </p>
                      {isCorrect ? null : (
                        <p>
                          Jawaban benar:{' '}
                          <span className="font-bold text-green-700">
                            {question.answer}. {question.options[question.answer]}
                          </span>
                        </p>
                      )}
                    </div>
                  </article>
                );
              })}
            </div>
          </section>
        </main>
      </Shell>
    );
  }

  return (
    <Shell>
      <div className="flex min-h-screen flex-col bg-slate-100">
        <header className="sticky top-0 z-30 border-b border-slate-200 bg-white">
          <div className="flex min-h-16 items-center justify-between gap-3 px-4 py-3 lg:px-6">
            <div className="flex min-w-0 items-center gap-3">
              <button
                onClick={() => setShowMobilePanel(true)}
                className="inline-flex h-10 w-10 items-center justify-center rounded-md border border-slate-300 text-slate-700 lg:hidden"
                aria-label="Buka daftar soal"
              >
                <Menu size={20} aria-hidden="true" />
              </button>
              <div className="min-w-0">
                <p className="truncate text-sm font-semibold text-blue-700">{examConfig.subject}</p>
                <h1 className="truncate text-base font-bold text-slate-950 sm:text-lg">{examConfig.title}</h1>
              </div>
            </div>
            <div className="flex items-center gap-2 rounded-md border border-blue-200 bg-blue-50 px-3 py-2 text-blue-900">
              <Clock3 size={18} aria-hidden="true" />
              <span className="min-w-[78px] text-right font-mono text-sm font-bold sm:text-base">{formatTime(secondsLeft)}</span>
            </div>
          </div>
        </header>

        <div className="grid flex-1 lg:grid-cols-[280px_1fr]">
          <QuestionPanel
            answers={answers}
            currentIndex={currentIndex}
            doubtful={doubtful}
            goToQuestion={goToQuestion}
            isMobile={false}
          />

          <main className="min-w-0 p-4 lg:p-6">
            <section className="mx-auto max-w-5xl rounded-lg border border-slate-200 bg-white shadow-soft">
              <div className="border-b border-slate-200 p-4 sm:p-6">
                <div className="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
                  <div>
                    <p className="text-sm font-semibold text-slate-500">Soal {currentIndex + 1} dari {questions.length}</p>
                    <h2 className="mt-2 text-lg font-bold leading-7 text-slate-950 sm:text-xl">{currentQuestion.text}</h2>
                  </div>
                  <StatusPill answered={Boolean(answers[currentQuestion.id])} doubtful={Boolean(doubtful[currentQuestion.id])} />
                </div>
                {currentQuestion.image ? (
                  <img
                    src={currentQuestion.image}
                    alt={`Ilustrasi soal ${currentIndex + 1}`}
                    className="mt-5 max-h-80 w-full rounded-md border border-slate-200 object-cover"
                  />
                ) : null}
              </div>

              <div className="space-y-3 p-4 sm:p-6">
                {Object.entries(currentQuestion.options).map(([key, value]) => {
                  const selected = answers[currentQuestion.id] === key;
                  return (
                    <button
                      key={key}
                      onClick={() => chooseAnswer(key)}
                      className={`flex w-full items-start gap-3 rounded-md border p-4 text-left transition focus:outline-none focus:ring-4 focus:ring-blue-100 ${
                        selected
                          ? 'border-blue-600 bg-blue-50 text-blue-950'
                          : 'border-slate-200 bg-white text-slate-700 hover:border-blue-300 hover:bg-slate-50'
                      }`}
                    >
                      <span
                        className={`flex h-8 w-8 shrink-0 items-center justify-center rounded-md text-sm font-bold ${
                          selected ? 'bg-blue-700 text-white' : 'bg-slate-100 text-slate-700'
                        }`}
                      >
                        {key}
                      </span>
                      <span className="pt-1 text-sm leading-6 sm:text-base">{value}</span>
                    </button>
                  );
                })}
              </div>

              <div className="flex flex-col gap-3 border-t border-slate-200 p-4 sm:flex-row sm:items-center sm:justify-between sm:p-6">
                <button
                  onClick={toggleDoubtful}
                  className={`flex items-center justify-center gap-2 rounded-md border px-4 py-3 font-semibold transition focus:outline-none focus:ring-4 focus:ring-yellow-100 ${
                    doubtful[currentQuestion.id]
                      ? 'border-yellow-300 bg-yellow-100 text-yellow-900'
                      : 'border-slate-300 bg-white text-slate-800 hover:bg-slate-50'
                  }`}
                >
                  <Flag size={18} aria-hidden="true" />
                  Tandai Ragu-ragu
                </button>
                <div className="grid grid-cols-2 gap-3 sm:flex">
                  <button
                    onClick={() => goToQuestion(Math.max(currentIndex - 1, 0))}
                    disabled={currentIndex === 0}
                    className="flex items-center justify-center gap-2 rounded-md border border-slate-300 bg-white px-4 py-3 font-semibold text-slate-800 transition hover:bg-slate-50 disabled:cursor-not-allowed disabled:opacity-45"
                  >
                    <ArrowLeft size={18} aria-hidden="true" />
                    Sebelumnya
                  </button>
                  {currentIndex === questions.length - 1 ? (
                    <button
                      onClick={() => setShowSubmitConfirm(true)}
                      className="flex items-center justify-center gap-2 rounded-md bg-blue-700 px-4 py-3 font-semibold text-white transition hover:bg-blue-800 focus:outline-none focus:ring-4 focus:ring-blue-200"
                    >
                      <Send size={18} aria-hidden="true" />
                      Submit
                    </button>
                  ) : (
                    <button
                      onClick={() => goToQuestion(Math.min(currentIndex + 1, questions.length - 1))}
                      className="flex items-center justify-center gap-2 rounded-md bg-blue-700 px-4 py-3 font-semibold text-white transition hover:bg-blue-800 focus:outline-none focus:ring-4 focus:ring-blue-200"
                    >
                      Berikutnya
                      <ArrowRight size={18} aria-hidden="true" />
                    </button>
                  )}
                </div>
              </div>
            </section>
          </main>
        </div>

        {showMobilePanel ? (
          <div className="fixed inset-0 z-40 bg-slate-950/40 lg:hidden" role="dialog" aria-modal="true">
            <div className="h-full w-[86vw] max-w-sm bg-white shadow-soft">
              <div className="flex items-center justify-between border-b border-slate-200 p-4">
                <p className="font-bold text-slate-950">Daftar Soal</p>
                <button
                  onClick={() => setShowMobilePanel(false)}
                  className="flex h-9 w-9 items-center justify-center rounded-md border border-slate-300 text-slate-700"
                  aria-label="Tutup daftar soal"
                >
                  <X size={18} aria-hidden="true" />
                </button>
              </div>
              <QuestionPanel
                answers={answers}
                currentIndex={currentIndex}
                doubtful={doubtful}
                goToQuestion={goToQuestion}
                isMobile
              />
            </div>
          </div>
        ) : null}

        {showSubmitConfirm ? (
          <ConfirmModal
            answeredCount={answeredCount}
            doubtfulCount={doubtfulCount}
            unansweredCount={summary.unanswered}
            onCancel={() => setShowSubmitConfirm(false)}
            onConfirm={finishExam}
          />
        ) : null}
      </div>
    </Shell>
  );
}

function Shell({ centered = false, children }) {
  return (
    <div className={centered ? 'flex min-h-screen items-center justify-center bg-slate-100 p-4' : 'min-h-screen bg-slate-100'}>
      {children}
      <Watermark />
    </div>
  );
}

function Watermark() {
  return (
    <a
      href="https://www.instagram.com/imaddd24_/"
      target="_blank"
      rel="noreferrer"
      className="fixed bottom-3 right-3 z-[60] rounded-md border border-slate-200 bg-white/90 px-3 py-1.5 text-xs font-semibold text-slate-500 shadow-sm backdrop-blur transition hover:border-blue-200 hover:text-blue-700 focus:outline-none focus:ring-4 focus:ring-blue-100"
      aria-label="Buka Instagram MadeSurya24"
    >
      Web by MadeSurya24
    </a>
  );
}

function Info({ label, value }) {
  return (
    <div className="rounded-md border border-slate-200 bg-slate-50 p-3">
      <p className="text-xs font-semibold uppercase tracking-[0.12em] text-slate-500">{label}</p>
      <p className="mt-1 truncate font-semibold text-slate-900">{value}</p>
    </div>
  );
}

function QuestionPanel({ answers, currentIndex, doubtful, goToQuestion, isMobile }) {
  return (
    <aside className={`${isMobile ? 'h-[calc(100%-65px)]' : 'hidden border-r border-slate-200 bg-white lg:block'} overflow-y-auto scrollbar-thin`}>
      <div className="p-4 lg:sticky lg:top-16">
        {!isMobile ? (
          <div className="mb-5">
            <p className="text-sm font-semibold text-slate-500">Navigasi Soal</p>
            <h2 className="text-lg font-bold text-slate-950">Daftar Nomor</h2>
          </div>
        ) : null}

        <div className="grid grid-cols-5 gap-2 sm:grid-cols-6 lg:grid-cols-5">
          {questions.map((question, index) => {
            const isActive = index === currentIndex;
            const isAnswered = Boolean(answers[question.id]);
            const isDoubtful = Boolean(doubtful[question.id]);
            const statusClass = isDoubtful
              ? 'border-yellow-300 bg-yellow-100 text-yellow-900'
              : isAnswered
                ? 'border-blue-600 bg-blue-700 text-white'
                : 'border-slate-300 bg-white text-slate-700';

            return (
              <button
                key={question.id}
                onClick={() => goToQuestion(index)}
                className={`aspect-square rounded-md border text-sm font-bold transition hover:scale-[1.02] focus:outline-none focus:ring-4 focus:ring-blue-100 ${statusClass} ${
                  isActive ? 'ring-2 ring-blue-300 ring-offset-2' : ''
                }`}
                aria-label={`Soal ${index + 1}`}
              >
                {index + 1}
              </button>
            );
          })}
        </div>

        <div className="mt-6 space-y-2 text-sm text-slate-600">
          <Legend color="bg-white border-slate-300" label="Belum dijawab" />
          <Legend color="bg-blue-700 border-blue-700" label="Sudah dijawab" />
          <Legend color="bg-yellow-100 border-yellow-300" label="Ragu-ragu" />
        </div>
      </div>
    </aside>
  );
}

function Legend({ color, label }) {
  return (
    <div className="flex items-center gap-2">
      <span className={`h-4 w-4 rounded border ${color}`} aria-hidden="true" />
      <span>{label}</span>
    </div>
  );
}

function StatusPill({ answered, doubtful }) {
  if (doubtful) {
    return (
      <span className="inline-flex w-max items-center gap-2 rounded-md bg-yellow-100 px-3 py-2 text-sm font-semibold text-yellow-900">
        <Flag size={16} aria-hidden="true" />
        Ragu-ragu
      </span>
    );
  }
  if (answered) {
    return (
      <span className="inline-flex w-max items-center gap-2 rounded-md bg-blue-50 px-3 py-2 text-sm font-semibold text-blue-800">
        <CheckCircle2 size={16} aria-hidden="true" />
        Sudah dijawab
      </span>
    );
  }
  return (
    <span className="inline-flex w-max items-center gap-2 rounded-md bg-slate-100 px-3 py-2 text-sm font-semibold text-slate-700">
      <AlertCircle size={16} aria-hidden="true" />
      Belum dijawab
    </span>
  );
}

function ConfirmModal({ answeredCount, doubtfulCount, unansweredCount, onCancel, onConfirm }) {
  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-slate-950/50 p-4" role="dialog" aria-modal="true">
      <section className="w-full max-w-md rounded-lg bg-white p-6 shadow-soft">
        <div className="flex h-12 w-12 items-center justify-center rounded-md bg-blue-50 text-blue-700">
          <Send size={24} aria-hidden="true" />
        </div>
        <h2 className="mt-5 text-xl font-bold text-slate-950">Submit jawaban?</h2>
        <p className="mt-2 text-sm leading-6 text-slate-600">
          Pastikan semua jawaban sudah diperiksa. Setelah submit, hasil ujian akan langsung ditampilkan.
        </p>
        <div className="mt-5 grid grid-cols-3 gap-2 text-center text-sm">
          <MiniStat label="Dijawab" value={answeredCount} />
          <MiniStat label="Ragu" value={doubtfulCount} />
          <MiniStat label="Kosong" value={unansweredCount} />
        </div>
        <div className="mt-6 grid grid-cols-2 gap-3">
          <button
            onClick={onCancel}
            className="rounded-md border border-slate-300 bg-white px-4 py-3 font-semibold text-slate-800 transition hover:bg-slate-50"
          >
            Cek Lagi
          </button>
          <button
            onClick={onConfirm}
            className="rounded-md bg-blue-700 px-4 py-3 font-semibold text-white transition hover:bg-blue-800 focus:outline-none focus:ring-4 focus:ring-blue-200"
          >
            Ya, Submit
          </button>
        </div>
      </section>
    </div>
  );
}

function HistoryDetail({ attempt }) {
  return (
    <div className="max-h-[calc(100vh-180px)] overflow-auto p-4 scrollbar-thin sm:p-6">
      <div className="rounded-lg border border-slate-200 bg-slate-50 p-4">
        <div className="flex flex-col gap-3 sm:flex-row sm:items-start sm:justify-between">
          <div>
            <p className="text-sm font-semibold text-blue-700">Detail Peserta</p>
            <h2 className="mt-1 text-xl font-bold text-slate-950">{attempt.participant.name}</h2>
            <p className="mt-1 text-sm text-slate-600">Nomor peserta: {attempt.participant.number}</p>
            <p className="mt-1 text-sm text-slate-600">Submit: {formatDateTime(attempt.finishedAt)}</p>
          </div>
          <div className="rounded-lg bg-blue-700 px-5 py-3 text-center text-white">
            <p className="text-xs font-semibold text-blue-100">Skor</p>
            <p className="text-3xl font-bold">{attempt.result.score}</p>
          </div>
        </div>
        <div className="mt-4 grid gap-2 sm:grid-cols-4">
          <ResultCard label="Benar" value={attempt.result.correct} tone="green" />
          <ResultCard label="Salah" value={attempt.result.wrong} tone="red" />
          <ResultCard label="Tidak Dijawab" value={attempt.result.unanswered} tone="slate" />
          <ResultCard label="Total Soal" value={attempt.result.total} tone="blue" />
        </div>
      </div>

      <div className="mt-5 space-y-4">
        {questions.map((question, index) => {
          const chosen = attempt.answers[question.id];
          const isCorrect = chosen === question.answer;
          const isUnanswered = !chosen;
          const statusLabel = isUnanswered ? 'Tidak dijawab' : isCorrect ? 'Benar' : 'Salah';
          const statusClass = isUnanswered
            ? 'border-slate-200 bg-slate-100 text-slate-700'
            : isCorrect
              ? 'border-green-200 bg-green-50 text-green-800'
              : 'border-red-200 bg-red-50 text-red-800';

          return (
            <article key={question.id} className="rounded-lg border border-slate-200 bg-white p-4">
              <div className="flex flex-wrap items-center gap-2">
                <span className="rounded-md bg-slate-900 px-2.5 py-1 text-sm font-bold text-white">Soal {index + 1}</span>
                <span className={`rounded-md border px-2.5 py-1 text-sm font-bold ${statusClass}`}>{statusLabel}</span>
              </div>
              <h3 className="mt-3 text-sm font-bold leading-6 text-slate-950 sm:text-base">{question.text}</h3>

              {question.image ? (
                <img
                  src={question.image}
                  alt={`Gambar soal ${index + 1}`}
                  className="mt-4 max-h-56 w-full rounded-md border border-slate-200 object-contain"
                />
              ) : null}

              <div className="mt-4 rounded-md bg-slate-50 p-3 text-sm leading-6 text-slate-700">
                <p>
                  Jawaban peserta:{' '}
                  <span className="font-bold text-slate-950">
                    {chosen ? `${chosen}. ${question.options[chosen]}` : 'Tidak dijawab'}
                  </span>
                </p>
                {!isCorrect ? (
                  <p>
                    Jawaban benar:{' '}
                    <span className="font-bold text-green-700">
                      {question.answer}. {question.options[question.answer]}
                    </span>
                  </p>
                ) : null}
              </div>
            </article>
          );
        })}
      </div>
    </div>
  );
}

function MiniStat({ label, value }) {
  return (
    <div className="rounded-md bg-slate-100 p-3">
      <p className="font-bold text-slate-950">{value}</p>
      <p className="mt-1 text-xs text-slate-600">{label}</p>
    </div>
  );
}

function ReviewLegend({ label, value, tone }) {
  const toneClass = {
    green: 'border-green-200 bg-green-50 text-green-800',
    red: 'border-red-200 bg-red-50 text-red-800',
    slate: 'border-slate-200 bg-white text-slate-800',
  }[tone];

  return (
    <div className={`rounded-lg border p-4 ${toneClass}`}>
      <p className="text-sm font-semibold">{label}</p>
      <p className="mt-1 text-2xl font-bold">{value}</p>
    </div>
  );
}

function ResultCard({ label, value, tone }) {
  const toneClass = {
    green: 'border-green-200 bg-green-50 text-green-800',
    red: 'border-red-200 bg-red-50 text-red-800',
    slate: 'border-slate-200 bg-slate-50 text-slate-800',
    blue: 'border-blue-200 bg-blue-50 text-blue-800',
  }[tone];

  return (
    <div className={`rounded-lg border p-4 ${toneClass}`}>
      <p className="text-sm font-semibold">{label}</p>
      <p className="mt-2 text-3xl font-bold">{value}</p>
    </div>
  );
}

export default App;
